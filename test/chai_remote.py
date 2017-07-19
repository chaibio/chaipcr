
import sys
import os
import requests
import json
import time
import pickle
import paramiko
import sshtunnel
import MySQLdb
import pandas as pd
import numpy as np
from datetime import datetime
import chai_util as util

def _request2curl(req):
    """Convert python requests to curl syntax.
    
    Should be called with ret.request as parameter,
    where ret is the return value from a requests.Session action (e.g. get, put, etc.)
    """

    command = "curl -X {method} -H {headers} -d '{data}' '{uri}'"
    method = req.method
    uri = req.url
    data = req.body
    headers = ["'{0}: {1}'".format(k, v) for k, v in req.headers.items()]
    headers = " -H ".join(headers)
    return command.format(method=method, headers=headers, data=data, uri=uri)


class ChaiDevice(object):
    """Device class.

    Communicates with the device using the REST API and/or ssh
    """
    
    def __init__(self, host=None, config='chai_config.json', email=None, passwd=None, ssh_user=None, ssh_passwd=None):
        """Constructor
        
        Connection parameters can be passed directly, or read from a configuration file.
        Explicit parameters override the configuration file
        
        """

        self._config = {}
        try:
            self._config = json.load(open(config))
        except:
            # Could not read the config file
            pass

        
        for par in ['host', 'email', 'passwd', 'ssh_user', 'ssh_passwd']:
            if locals()[par]:
                self._config[par] = locals()[par]

            if not par in self._config:
                raise Exception('Missing "%s" parameter'%par)

        self._rest_prefix = 'http://' + self._config['host'] 

        self._rest_session = requests.Session()
        self.connect_rest()
        
        self._ssh_session = paramiko.SSHClient()
        # should this be more restrictive?
        self._ssh_session.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.connect_ssh()

        print("Connection successful")

        self.data_logger_samplerate = 80 #Hz or samples/s


    def connect_rest(self):
        """Connect to the device using the REST API."""
        try:
            ret = self._rest_session.post(self._rest_prefix + '/login', params={"email":self._config['email'], "password":self._config['passwd']})
            token = ret.json()['authentication_token']
            self._rest_session.headers.update({"Authorization":"Token " + token})
        except:
            raise Exception("Failed to establish REST connection to machine: '%s'"%self._config['host'] )


    def connect_ssh(self):
        """Connect to the device using ssh."""
        try:
            self._ssh_session.connect(self._config['host'], username = self._config['ssh_user'], password = self._config['ssh_passwd'])
        except:
            raise Exception("Failed to establish ssh connection to machine: '%s'"%self._config['host'] )


    def status(self):

        ret = self._rest_session.get(self._rest_prefix + '/device/status')
        return ret.json()


    def state(self):

        return self.status()['experiment_controller']['machine']['state']
    

    def experiment_start(self, experiment_id=None):
        
        util.check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.post(self._rest_prefix + ':8000/control/start', data='{"experiment_id":"%d"}'%experiment_id)
        status = True
        try:
            if ret.json()['status']['status'] == 'true':
                return True
            else:
                raise Exception('Failed to start experiment %d. (%s)'%(experiment_id, ret.json()['status']['error']))
        except KeyError:
            raise Exception('Invalid reply from instrument')


    def experiment_stop(self):

        ret = self._rest_session.post(self._rest_prefix + ':8000/control/stop')

        try:
            if ret.json()['status']['status'] == 'true':
                return True
            else:
                raise Exception('Failed to stop current experiment (%s)'%ret.json()['status']['error'])
        except KeyError:
            raise Exception('Invalid reply from instrument')
                

    def experiment_delete(self, experiment_id=None):

        util.check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.delete(self._rest_prefix + '/experiments/%d'%experiment_id)

        if 'experiment' in ret.json() and not ret.json()['experiment']:
            return True
        else:
            raise Exception('Failed to delete experiment id %d'%experiment_id)


    def experiment_copy(self, experiment_id=None, name=None):
        """Copy an existing experiment.

        Returns the id of the new experiment.
        """
        util.check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.post(self._rest_prefix + '/experiments/%d/copy'%experiment_id)
        new_experiment_id = -1
        try:
            new_experiment_id = int(ret.json()['experiment']['id'])
        except:
            raise Exception('Failed to copy experiment id %d'%experiment_id)

        if name:
            ret = self._rest_session.put(
                    self._rest_prefix + '/experiments/%d'%new_experiment_id,
                    headers={'Content-Type':'application/json'}, 
                    data=json.dumps({'experiment':{'name':name}})
                    )

        return new_experiment_id


    def experiment_info(self, experiment_id=None):
        """Get status of an experiment."""

        util.check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.get(self._rest_prefix + '/experiments/%d'%experiment_id)
        try:
            return ret.json()
        except:
            raise Exception('Failed to get experiment id %d'%experiment_id)


    def experiment_loop(
                   self, 
                   experiment_id=None, 
                   loop_cnt=100, 
                   data_log=False, data_log_duration_s=None, 
                   poll_seconds=60, gap_minutes=1, 
                   stop_on_error=True, 
                   delete_loop_experiments=False
                   ):
        """Run the same experiment in a loop.

        Copies of the experiments are created, run and optionally deleted.
        """

        if self.state() != 'idle':
            raise Exception('Device is running an experiment')

        util.check_par('experiment id', experiment_id, _type=int, _min=0)
        util.check_par('loop count', loop_cnt, _type=int, _min=1, _max=1000)
        util.check_par('poll seconds', poll_seconds, _type=int, _min=1, _max=3600)
        util.check_par('gap minutes', gap_minutes, _type=int, _min=0, _max=1440)

        exp_info = self.experiment_info(experiment_id)
        if data_log:
            if data_log_duration_s != None:
                util.check_par('data log duration (seconds)', data_log_duration_s, _type=int, _min=1)
            else:
                if exp_info['experiment']['completion_status'] != 'success':
                    raise Exception("Template experiment did not complete successfully. Please specify the data_log_duration_s parameter")
                try:
                    start_time = datetime.strptime(exp_info['experiment']['started_at'], '%Y-%m-%dT%H:%M:%S.000Z')
                    end_time = datetime.strptime(exp_info['experiment']['completed_at'], '%Y-%m-%dT%H:%M:%S.000Z')
                except:
                    raise Exception("Failed to detect experiment duration.")

                duration = end_time - start_time
                if duration.days != 0:
                    raise Exception("Detected invalid experiment duration (days): %d"%duration.days)
                if duration.seconds < 0 or duration.seconds > 12*3600:
                    raise Exception("Detected invalid experiment duration (seconds): %d"%duration.seconds)
                data_log_duration_s = duration.seconds + 60

        data={}

        for loop in range(1, loop_cnt+1):

            new_id = self.experiment_copy(experiment_id, name = exp_info['experiment']['name'] + '_loop_%d'%loop)
            print("Starting loop %d with experiment id %d"%(loop, new_id))

            if data_log:
                self.data_logger_start(int(1.2 * data_log_duration_s) * self.data_logger_samplerate, 10)

            self.experiment_start(new_id)
            time.sleep(10)
            if self.state() == 'idle':
                raise Exception('Failed to start loop %d for experiment id %d'%(loop, new_id))

            while True:
                time.sleep(poll_seconds)
                if self.state() == 'idle':
                    break;

            if data_log:
                data[new_id] = self.data_logger_trigger(timeout_s = 60)
                self.data_logger_stop()
                pickle.dump(data, open('data_%s'%self._config['host'], 'wb'))
            
            if stop_on_error and self.experiment_info(new_id)['experiment']['completion_status'] != 'success':
                raise Exception('Loop %d for experiment id %d failed'%(loop, new_id))

            time.sleep(gap_minutes * 60)

            if delete_loop_experiments:
                try:
                    self.experiment_delete(new_id)
                except:
                    print('Failed to delete experiment id %d'%new_id)

            time.sleep(10)

            # renew connection authorization
            self.connect_rest()

        print("Finished %d loops for experiment id %d"%(loop, experiment_id))

        return data


    def experiment_get_template(self, experiment_id=None):
        """Retrieve the template for an experiment.

        Can be used to duplicate the experiment on another machine.
        """

        util.check_par('experiment id', experiment_id, _type=int, _min=0)

        exp = self._rest_session.get(self._rest_prefix + '/experiments/%d'%experiment_id)

        try:
            exp = exp.json()
            exp['experiment']['id']
        except:
            raise Exception('Failed to get template for experiment id %d'%experiment_id)

       
        # build the template protocol
        ret_proto = {}
        ret_proto['lid_temperature'] = exp['experiment']['protocol']['lid_temperature']
        for stage in exp['experiment']['protocol']['stages']:
            stage['stage'].pop('id')
            for step in stage['stage']['steps']:
                step['step'].pop('id')
        ret_proto['stages'] = exp['experiment']['protocol']['stages']

        ret = {'experiment':{'name':exp['experiment']['name'], 'protocol':ret_proto}}

        return ret


    def experiment_load(self, template=None, name=None):
        """Load experiment from a template."""

        try:
            template['experiment']['protocol']
            template['experiment']['name']
        except:
            raise Exception('Invalid template: %s'%str(template))
        
        if name:
            template['experiment']['name'] = str(name)


        ret = self._rest_session.post(
                self._rest_prefix + '/experiments', 
                headers={'Content-Type':'application/json'}, 
                data=json.dumps(template)
                )

        try:
            return int(ret.json()['experiment']['id'])
        except:
            raise Exception('Failed to load experiment')


    def test_control(self, item, value):
        """Access the test_control REST API."""

        ret = self._rest_session.put(
                self._rest_prefix + ':8000/test_control', 
                headers={'Content-Type':'application/json'}, 
                data=json.dumps({item:value})
                )

        try:
            if ret.json()['status']['status'] == 'true':
                return True
        except:
            return False

        return False


    def ssh_command(self, command, stdin=None):
        """Execute a remote command over ssh.

        Returns a tuple with (return_code, combined_stdout_stderr)
        """
        try:

            chan = self._ssh_session.get_transport().open_session()
            chan.get_pty()
            f = chan.makefile()
            if stdin:
                f.write(stdin)
            chan.exec_command(command)

            return (chan.recv_exit_status(), f)

        except:
            raise Exception('Failed to execute command: "%s"'%command)


    def sql_command(self, command):
        """Execute an sql command and return the results.
        
        The db connection is established over an ssh tunnel
        """

        try:
            with sshtunnel.SSHTunnelForwarder(
                    (self._config['host'], 22),
                    ssh_username = self._config['ssh_user'],
                    ssh_password = self._config['ssh_passwd'],
                    remote_bind_address=('127.0.0.1', 3306),
                    local_bind_address=('0.0.0.0', 8306)
                ) as tunnel:
                db = MySQLdb.connect(
                        host = '127.0.0.1',
                        port = 8306,
                        user = 'root',
                        passwd = '',
                        db = 'chaipcr'
                        )
                data = pd.read_sql(command+';', con=db)
                db.close()
                return data
                
        except Exception as e:
            raise Exception('Failed to access database')

    def sql_get_data(self, table, experiment_id, channel=None, well=None):
        """Get data for a specific experiment."""

        util.check_par('experiment id', experiment_id, _type=int, _min=0)

        channel_string = ''
        if channel is not None:
            util.check_par('channel', channel, _type=int, _min=1, _max=2)
            channel_string = 'and channel = %d'%(int(channel))

        well_string = ''
        if well is not None:
            util.check_par('well number', well, _type=int, _min=0, _max=15)
            well_string = 'and well_num = %d'%(int(well))

        data = self.sql_command(
                "select * from %s where experiment_id = %d %s %s"%(table, experiment_id, channel_string, well_string)
               )
        return data


    def sftp_get(self, remote_path, local_path):
        """Transfer a file from device."""

        try:
            sftp = self._ssh_session.open_sftp()
            sftp.get(remote_path, local_path)
        except:
            raise Exception('Failed to get file "%s"'%remote_path)

    def sftp_put(self, local_path, remote_path):
        """Transfer a file from device."""

        try:
            sftp = self._ssh_session.open_sftp()
            sftp.put(local_path, remote_path)
        except:
            raise Exception('Failed to send file "%s"'%local_path)


    def set_heat_block_temp(self, temp, tol=0.5):
        
        util.check_par('temperature', temp, _type=float, _min=0, _max=100)
        util.check_par('tolerance', tol, _type=float, _min=0, _max=5)

        self.test_control('heat_block_target_temp','%d'%temp)

        while True:
            time.sleep(1)
            if abs(temp - float(self.status()['heat_block']['temperature'])) <= tol:
                break


    def read_well(self, well, cnt, mode='status', source_on=True):
        """Get optical readings from the status page or from the csv dump"""

        
        util.check_par('well', well, int, 0, 15)
        util.check_par('sample count', cnt, int, 0)
        util.check_par('mode', mode, str, _list=['status', 'dump'])
        util.check_par('source on', source_on, bool, _list=[True, False])

        self.test_control("photodiode_mux_channel",'%d'%well)

        if source_on:
            self.test_control("activate_led",'%d'%well)
        else:
            self.test_control("disable_leds",'')

        time.sleep(0.5)

        ret = []
        if mode == 'status':
            for i in range(cnt):
                ret.append([int(i) for i in self.status()['optics']['photodiode_value']])
            
            ret = pd.DataFrame(ret)
            ret.columns = ['optics_%d'%(i+1) for i in range(ret.columns.size)]

            self.test_control("disable_leds",'')

        elif mode == 'dump':
            self.data_logger_start(10, cnt-10)
            ret = self.data_logger_trigger()

            self.test_control("disable_leds",'')

            ret = ret[[c for c in list(ret.columns) if c.startswith('optics')]]
        else:
            raise Exception('Unknown mode: %s'%mode)

        return ret


    def data_logger_start(self, cnt_pre, cnt_post):
        """Setup and start the data logger"""

        util.check_par('pre-trigger sample count', cnt_pre, int, _min = 0)
        util.check_par('post-trigger sample count', cnt_post, int, _min = 0)

        ret = self._rest_session.post(
                self._rest_prefix + ':8000/test/data_logger/start', 
                headers={'Content-Type':'application/json'}, 
                data=json.dumps({'pre_samples':'%d'%cnt_pre, 'post_samples':'%d'%cnt_post,})
                )

        try:
            if ret.json()['status']['status'] == 'true':
                return True
            else:
                raise Exception('Failed to start data logger (%s)'%ret.json()['status']['error'])
        except KeyError:
            raise Exception('Invalid reply from instrument')


    def data_logger_stop(self):
        """Stop the data logger"""

        ret = self._rest_session.post(
                self._rest_prefix + ':8000/test/data_logger/stop', 
                headers={'Content-Type':'application/json'} 
                )

        try:
            if ret.json()['status']['status'] == 'true':
                return True
            else:
                raise Exception('Failed to stop data logger (%s)'%ret.json()['status']['error'])
        except KeyError:
            raise Exception('Invalid reply from instrument')


    def data_logger_trigger(self, timeout_s=None):
        """Wait for logger data and retrieve it"""

        if timeout_s != None:
            util.check_par('timeout (seconds)', timeout_s, int, _min=1)

        remote_output_file = '/tmp/data_logger.csv'
        local_output_file = 'data.csv.%s'%self._config['host']
        self.ssh_command('rm -f ' + remote_output_file)

        ret = self._rest_session.post(
                self._rest_prefix + ':8000/test/data_logger/trigger', 
                headers={'Content-Type':'application/json'} 
                )
        try:
            if ret.json()['status']['status'] != 'true':
                raise Exception('Failed to trigger data logger (%s)'%ret.json()['status']['error'])
        except KeyError:
            raise Exception('Invalid reply from instrument')

        ret = []

        while True:
            if timeout_s != None:
                if timeout_s < 0:
                    return False
                else:
                    timeout_s -= 10

            time.sleep(10)
            ret = self.ssh_command('stat ' + remote_output_file)
            if ret[0] == 0:
                # file exists
                time.sleep(1)
                break

        self.sftp_get(remote_output_file, local_output_file)

        ret = pd.read_csv(local_output_file, header=0)
        ret = ret.set_index(['time_offset'])

        return ret


def main():
    
    import pprint
    dev = ChaiDevice('my_device_IP_address')
    pprint.pprint(dev.status())
    

if __name__=='__main__':
    sys.exit(main())


