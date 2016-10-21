
import sys
import os
import requests
import json
import time
import paramiko
import pandas as pd
import numpy as np

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


def _check_par(name, value, _type=int, _min=None, _max=None, _list=None):
    """Check parameters."""

    if not value or not isinstance(value, _type):
        raise Exception('Value of parameter %s is not a valid %s.'%(name, _type))

    if _list and value not in _list:
        raise Exception('Value of parameter %s is not in the valid list %s.'%(name, _list))

    if _min and value < _min:
        raise Exception('Value of parameter %s is less than the min value %s.'%(name, _min))

    if _max and value > _max:
        raise Exception('Value of parameter %s is more than the max value %s.'%(name, _max))

class ChaiDevice():
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

            if not self._config.has_key(par):
                raise Exception('Missing "%s" parameter'%par)

        self._rest_prefix = 'http://' + self._config['host'] 

        self._rest_session = requests.Session()
        self.connect_rest()
        
        self._ssh_session = paramiko.SSHClient()
        # should this be more restrictive?
        self._ssh_session.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.connect_ssh()


        print("Connection successful")


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
        
        _check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.post(self._rest_prefix + ':8000/control/start', data='{"experiment_id":"%d"}'%experiment_id)
        try:
            if ret.json()['status']['status'] == 'true':
                return True
            else:
                return False
        except:
            raise Exception('Failed to stop current experiment')

    def experiment_stop(self):

        ret = self._rest_session.post(self._rest_prefix + ':8000/control/stop')

        try:
            if ret.json()['status']['status'] == 'true':
                return True
            else:
                return False
        except:
            raise Exception('Failed to stop current experiment')
                
    def experiment_delete(self, experiment_id=None):

        _check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.delete(self._rest_prefix + '/experiments/%d'%experiment_id)

        if ret.json().has_key('experiment') and not ret.json()['experiment']:
            return True
        else:
            raise Exception('Failed to delete experiment id %d'%experiment_id)

    def experiment_copy(self, experiment_id=None):
        """Copy an existing experiment.

        Returns the id of the new experiment.
        """
        _check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.post(self._rest_prefix + '/experiments/%d/copy'%experiment_id)
        try:
            return int(ret.json()['experiment']['id'])
        except:
            raise Exception('Failed to copy experiment id %d'%experiment_id)

    def experiment_info(self, experiment_id=None):
        """Get status of an experiment."""

        _check_par('experiment id', experiment_id, _type=int, _min=0)

        ret = self._rest_session.get(self._rest_prefix + '/experiments/%d'%experiment_id)
        try:
            return ret.json()
        except:
            raise Exception('Failed to get experiment id %d'%experiment_id)

    def experiment_loop(self, experiment_id=None, loop_cnt=100, poll_seconds=60, gap_minutes=5, stop_on_error=True, delete_loop_experiments=True):
        """Run the same experiment in a loop.

        Copies of the experiments are created, run and optionally deleted.
        """

        if self.state() != 'idle':
            raise Exception('Device is running an experiment')

        _check_par('experiment id', experiment_id, _type=int, _min=0)

        try:
            int_loop_cnt = int(loop_cnt)
            if int(loop_cnt) < 1 or int(loop_cnt) > 1000:
                raise Exception('loop_cnt must be between 1 and 1000 (default 10)')
        except:
            raise Exception('Invalid loop_cnt')

        try:
            int_poll_seconds = int(poll_seconds)
            if int(poll_seconds) < 1 or int(poll_seconds) > 3600:
                raise Exception('poll_seconds must be between 1 and 3600 (default 60')
        except:
            raise Exception('Invalid poll_seconds')

        try:
            int_gap_minutes = int(gap_minutes)
            if int(gap_minutes) < 0 or int(gap_minutes) > 1440:
                raise Exception('gap_minutes must be between 0 and 1440 (default 5')
        except:
            raise Exception('Invalid gap_minutes')

        for loop in xrange(1, int_loop_cnt+1):

            new_id = self.experiment_copy(experiment_id)
            print("Starting loop %d with experiment id %d"%(loop, new_id))
            self.experiment_start(new_id)
            time.sleep(10)
            if self.state() == 'idle':
                raise Exception('Failed to start loop %d for experiment id %d'%(loop, new_id))

            while True:
                time.sleep(int_poll_seconds)
                if self.state() == 'idle':
                    break;
            
            if stop_on_error and self.experiment_info(new_id)['experiment']['completion_status'] != 'success':
                raise Exception('Loop %d for experiment id %d failed'%(loop, new_id))

            time.sleep(int_gap_minutes * 60)

            if delete_loop_experiments:
                try:
                    self.experiment_delete(new_id)
                except:
                    print('Failed to delete experiment id %d'%new_id)

            time.sleep(10)

            # renew connection authorization
            self.connect_rest()

        print("Finished %d loops for experiment id %d"%(loop, experiment_id))


    def experiment_get_template(self, experiment_id=None):
        """Retrieve the template for an experiment.

        Can be used to duplicate the experiment on another machine.
        """

        _check_par('experiment id', experiment_id, _type=int, _min=0)

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

    def start_dump(self, sample_cnt):

        _check_par('sample count', sample_cnt, _min=1)

        ret = self._rest_session.post(
                self._rest_prefix + ':8000/test/log_adc_reads', 
                headers={'Content-Type':'application/json'}, 
                data=json.dumps({'num_samples':'%d'%sample_cnt})
                )

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
        
        _check_par('temperature', temp, _type=float, _min=0, _max=100)
        _check_par('tolerance', tol, _type=float, _min=0, _max=5)

        self.test_control('heat_block_target_temp','%d'%temp)

        while True:
            time.sleep(1)
            if abs(temp - float(self.status()['heat_block']['temperature'])) <= tol:
                break


    def read_well(self, well, cnt, mode='status', source_on=True):
        """Get optical readings from the status page or from the csv dump"""

        
        _check_par('well', well, int, 0, 15)
        _check_par('sample count', cnt, int, 0)
        _check_par('mode', mode, str, _list=['status', 'dump'])
        _check_par('source on', source_on, bool, _list=[True, False])

        self.test_control("photodiode_mux_channel",'%d'%well)

        if source_on:
            self.test_control("activate_led",'%d'%well)
        else:
            self.test_control("disable_leds",'')

        time.sleep(0.5)

        ret = []
        if mode == 'status':
            for i in xrange(cnt):
                ret.append([int(i) for i in self.status()['optics']['photodiode_value']])
            
            ret = pd.DataFrame(ret)
            ret.columns = ['ch%d'%(i+1) for i in xrange(ret.columns.size)]

            self.test_control("disable_leds",'')

        elif mode == 'dump':
            self.ssh_command('rm -f /tmp/adc_samples.csv')
            self.start_dump(cnt)
            while True:
                time.sleep(1)
                ret = self.ssh_command('stat /tmp/adc_samples.csv')
                if ret[0] == 0:
                    # file exists
                    time.sleep(1)
                    break

            self.test_control("disable_leds",'')

            self.sftp_get('/tmp/adc_samples.csv', 'adc_samples.csv')

            ret = pd.read_csv('adc_samples.csv', header=0)
            # TODO - fix this for single channel
            ret = ret[['5','7']]
            ret.columns = ['ch1', 'ch2']
        else:
            raise Exception('Unknown mode: %s'%mode)

        return ret

def main():
    
    import pprint
    dev = ChaiDevice('my_device_IP_address')
    pprint.pprint(dev.status())
    

if __name__=='__main__':
    sys.exit(main())


