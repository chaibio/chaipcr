import pandas as pd
import numpy as np
import time
import os
import sys
import shutil
import gzip
import json

import chai_util as util
import chai_remote as remote

class Status:
    PASS = 0
    WARN = 1
    FAIL = 2
    NONE = -1

def check_result(result, thresholds):
    """Check a numerical result.

    Thresholds should be a list [fail_min, warn_min, warn_max, fail_max]
    If a threshold value is not used should be set to None

    """
    status = Status.PASS
    if thresholds[1] and result < thresholds[1]:
        status = Status.WARN
    if thresholds[2] and result > thresholds[2]:
        status = Status.WARN
    if thresholds[0] and result < thresholds[0]:
        status = Status.FAIL
    if thresholds[3] and result > thresholds[3]:
        status = Status.FAIL

    return status


def status_string(status, format_s='{}', color=True):
    """Return the string reprsentation for the numeric status."""
    status_map ={
        Status.PASS : ('PASS', 'green'),
        Status.WARN : ('WARN', 'yellow'),
        Status.FAIL : ('FAIL', 'red'),
        Status.NONE : ('NONE', None)
        }
    
    if not status in status_map.keys():
        raise Exception('Unknown status "%s"'%status)

    style = None
    if color:
        style = status_map[status][1]

    return util._format(status_map[status][0], format_s, style)


class ChaiTest(object):
    """Base Test Class."""
    def __init__(self):
        self.device = None
        self.verbosity = 10
        self.logfile = None
        self.logdir = '.'
        self.label = self.__class__.__name__
        self.status = Status.NONE
        self.dump = True

    def dump_data(self):
        """Dump the test object to file."""
        if self.dump:
            # remove member objects which cannot be dumped
            tmp_logfile = self.logfile
            tmp_device = self.device
            self.logfile = None
            self.device = None
            
            util.pkl_gz_dump(self, os.path.join(self.logdir, self.label + '.pkl.gz'))

            # restore member 
            self.logfile = tmp_logfile
            self.device = tmp_device

    def run(self):
        """Run the test.
        
        Should be overriden in derived classes
        """
        pass

    def result_table(self, _print=True):
        """Return a table with test results."""
        pass

    def run_start(self):
        output = ''        
        output += '----------------------------\n'        
        output += 'Running test "%s"\n'%self.label        
        util.tee(output, self.logfile)

    def run_end(self):
        output = ''        
        output += 'Status : %s\n'%status_string(self.status, color = True)
        sys.stdout.write(output)
        if self.logfile:
            self.logfile.write(self.result_table(_print=False))

    def fan(self, on=True):

        if on:
            self.device.test_control('heat_sink_fan_drive', '1')
            time.sleep(1)
            self.device.test_control('heat_sink_fan_drive', '0.3')
        else:
            self.device.test_control('heat_sink_fan_drive', '0')


class ChaiNoiseTest(ChaiTest):
    """Noise Test."""
    def __init__(
            self,
            wells = range(16),
            temperatures_C = [10, 60, 80],
            loops = 300,
            settle_s = 300,
            leds_on = True,
            lid_temp_C = None
            ):

        self.wells = wells
        self.temperatures_C = temperatures_C
        self.loops = loops
        self.settle_s = settle_s
        self.leds_on = leds_on
        self.lid_temp_C = lid_temp_C
        

        super(ChaiNoiseTest, self).__init__()
        
        [util.check_par('well', well, _type=int, _min=0, _max=15) for well in self.wells] 
        [util.check_par('temperature (degC)', temp, _type=int, _min=0, _max=90) for temp in 
                [temp_number for temp_number in self.temperatures_C if temp_number != None]
                ] 
        util.check_par('loops', self.loops, _type=int, _min=0) 
        util.check_par('settle time (s)', self.settle_s, _type=int, _min=0, _max=3600) 

        self.logger_data = {}
        self.parsed_data = None
        self.results = None
        self.meas_values = {
                'avg_p2p' : [None, None, 300, 500], 
                'avg_diff': [None, None, 100, 200],
                'step_p2p': [None, None, 300, 500]
                }
        self.step_data_slice = slice(9,16)

    def run(self):

        super(ChaiNoiseTest, self).run_start()

        self.get_data()
        self.analyze_data()
        
        super(ChaiNoiseTest, self).run_end()
        
        return True


    def get_data(self):
        
        if len(self.wells) == 1:
            initial_well = (self.wells[0] + 1) % 16
        else:
            initial_well = self.wells[-1]

        try:

            self.device.experiment_stop()


            for temperature in self.temperatures_C:

                super(ChaiNoiseTest, self).fan(True)

                if self.lid_temp_C:
                    self.device.test_control('lid_target_temp', self.lid_temp_C)
                
                if self.verbosity > 0:
                    print('Setting block temperature to %.2f degC'%temperature)

                if temperature:
                    self.device.test_control('heat_block_target_temp', temperature)

                self.device.test_control('photodiode_mux_channel', initial_well)

                data_logger_buffer_size = int((1*self.loops*len(self.wells) + self.settle_s) * self.device.data_logger_samplerate)
                self.device.data_logger_start(data_logger_buffer_size - 10, 10)

                time.sleep(self.settle_s)

                for i in range(self.loops):
                    if self.verbosity > 1:
                        sys.stdout.write('.')
                        sys.stdout.flush()
                        if (i+1)%50 == 0:
                            sys.stdout.write('\n')
                            sys.stdout.flush()
                    for well in self.wells:

                        if self.leds_on:
                            self.device.test_control('activate_led', '%d'%well)
                        self.device.test_control('photodiode_mux_channel', '%d'%well)

                        time.sleep(0.3)

                self.device.test_control('photodiode_mux_channel', initial_well)

                self.logger_data[temperature] = self.device.data_logger_trigger()
                
                self.device.data_logger_stop()

                self.device.experiment_stop()

                if self.verbosity > 1:
                    print('')

                if data_logger_buffer_size <= self.logger_data[temperature].shape[0]:
                    print('Warning: Datalogger buffer size was too small and some data was lost')

                self.dump_data()

        finally:
            self.device.test_control('disable_leds', '')
            
            # remove this after the fix for the stop API is included in an official release
            self.device.test_control('heat_block_target_temp', '25')

            self.device.experiment_stop()

            #super(ChaiNoiseTest, self).fan(False)
            #self.device.test_control('lid_target_temp', 25)


    def analyze_data(self):

        temperatures_C = list(self.logger_data)

        channel_labels = {1:'optics_1', 2:'optics_2'}
        raw_data = self.logger_data[temperatures_C[0]]
        channels_col_idx = dict([(ch, raw_data.columns.get_loc(label)+1) for ch,label in channel_labels.items() if label in raw_data.columns])

        channels = channels_col_idx.keys()

        wells = list(set(raw_data['mux_channel']))

        results_index   = pd.MultiIndex.from_product( [temperatures_C, channels, wells, self.meas_values.keys()], names = ['temp', 'ch', 'well', 'meas'])
        self.results = pd.DataFrame(index=results_index, columns=['value', 'status'])

        self.parsed_data = {}
            
        for temperature in temperatures_C:

            raw_data = self.logger_data[temperature]

            parsed_data_buf = {}
            ch_data_buf = {}
            for ch in channels:
                parsed_data_buf[ch] = {}
                ch_data_buf[ch] = []
                for well in wells:
                    parsed_data_buf[ch][well] = []

            initial_well = raw_data.iloc[0].mux_channel
            last_well = initial_well

            for line in raw_data.itertuples():
                for ch, col_idx in channels_col_idx.items():
                    if line.mux_channel != last_well: 
                        parsed_data_buf[ch][last_well].append(ch_data_buf[ch][self.step_data_slice])
                        ch_data_buf[ch] = []
                    else:
                        ch_data_buf[ch].append(line[col_idx])
                last_well = line.mux_channel

            # remove data before the first mux transition
            for ch in channels:
                parsed_data_buf[ch][initial_well].pop(0)

            for ch in channels:
                for well in wells:

                    tmp = np.array(parsed_data_buf[ch][well])
                    step_avg = tmp.mean(axis=1)
                    step_avg_p2p = step_avg.ptp()
                    self.results.loc[(temperature,ch,well,'avg_p2p')]=[step_avg_p2p, check_result(step_avg_p2p, self.meas_values['avg_p2p'])]
                    step_avg_diff = np.diff(step_avg)
                    step_avg_diff_max = abs(step_avg_diff).max()
                    self.results.loc[(temperature,ch,well,'avg_diff')]=[step_avg_diff_max, check_result(step_avg_diff_max, self.meas_values['avg_diff'])]
                    step_p2p = tmp.ptp(axis=1)
                    step_p2p_max = step_p2p.max()
                    self.results.loc[(temperature,ch,well,'step_p2p')]=[step_p2p_max, check_result(step_p2p_max, self.meas_values['step_p2p'])]

            self.parsed_data[temperature] = parsed_data_buf

        self.status = self.results['status'].max()

    def result_table(self, _print=True):

        temperatures_C = self.results.index.get_level_values('temp').unique().sort_values()
        channels = self.results.index.get_level_values('ch').unique().sort_values()
        wells = self.results.index.get_level_values('well').unique().sort_values()
        color = _print

        output = ''
        output += '----------------------------\n'        
        header = self.results.index.names[:-1] + list(self.meas_values) + ['status']
        header = ['%8s'%i for i in header]
        output += ' '.join(header)
        output += '\n'

        for idx, df in self.results.groupby(level = ['temp', 'ch', 'well']):
            df = df.reset_index(level=[0,1,2])
            line = ['%s'%i for i in idx]
            line_status = []
            for meas in self.meas_values.keys():
                tmp = ''
                style = None
                if color:
                    if df['status'][meas] == Status.WARN:
                        style = 'yellow'
                    if df['status'][meas] == Status.FAIL:
                        style = 'red'
                tmp += util._format(df['value'][meas], '{:8.0f}'%df['value'][meas], style)
                line.append( tmp )
                line_status.append(df['status'][meas])  
            line.append(status_string(max(line_status), '{:>8s}', color))

            output += ' '.join(['%8s'%i for i in line])
            output += '\n'
        output += '----------------------------\n'        
        output += 'Test "%s" status : %s\n'%(self.label, status_string(self.status, '{:>8s}', color))

        if _print:
            print(output)
        else:
            return output


class ChaiThermalControlTest(ChaiTest):
    """Thermal Control Test."""
    def __init__(
            self, 
            ):

        super(ChaiThermalControlTest, self).__init__()
        
        self.logger_data = {}
        self.results = None
        self.template = {
                u'experiment': {u'name': u'Thermal Consistency',
                    u'protocol': {u'lid_temperature': u'110.0',
                        u'stages': [{u'stage': {u'auto_delta': False,
                            u'auto_delta_start_cycle': 1,
                            u'name': u'Holding Stage',
                            u'num_cycles': 1,
                            u'order_number': 0,
                            u'stage_type': u'holding',
                            u'steps': [{u'step': {u'collect_data': False,
                                u'delta_duration_s': 0,
                                u'delta_temperature': u'0.0',
                                u'hold_time': 30,
                                u'name': u'Denature',
                                u'order_number': 0,
                                u'pause': False,
                                u'ramp': {u'collect_data': False,
                                    u'id': 8,
                                    u'rate': u'0.0'},
                                u'temperature': u'95.0'}},
                                {u'step': {u'collect_data': False,
                                    u'delta_duration_s': 0,
                                    u'delta_temperature': u'0.0',
                                    u'hold_time': 60,
                                    u'name': u'Anneal',
                                    u'order_number': 1,
                                    u'pause': False,
                                    u'ramp': {u'collect_data': False,
                                        u'id': 9,
                                        u'rate': u'3.0'},
                                    u'temperature': u'60.0'}}]}},
                                {u'stage': {u'auto_delta': False,
                                    u'auto_delta_start_cycle': 1,
                                    u'name': u'Melt Curve Stage',
                                    u'num_cycles': 1,
                                    u'order_number': 1,
                                    u'stage_type': u'meltcurve',
                                    u'steps': [{u'step': {u'collect_data': False,
                                        u'delta_duration_s': 0,
                                        u'delta_temperature': u'0.0',
                                        u'hold_time': 15,
                                        u'name': u'Prepare melt',
                                        u'order_number': 0,
                                        u'pause': False,
                                        u'ramp': {u'collect_data': False,
                                            u'id': 10,
                                            u'rate': u'1.0'},
                                        u'temperature': u'72.0'}},
                                        {u'step': {u'collect_data': False,
                                            u'delta_duration_s': 0,
                                            u'delta_temperature': u'0.0',
                                            u'hold_time': 1,
                                            u'name': u'Melt',
                                            u'order_number': 1,
                                            u'pause': False,
                                            u'ramp': {u'collect_data': True,
                                                u'id': 11,
                                                u'rate': u'0.1'},
                                            u'temperature': u'85.0'}}]}}]}}}


    def run(self):

        super(ChaiThermalControlTest, self).run_start()

        self.get_data()
        self.analyze_data()
        
        super(ChaiThermalControlTest, self).run_end()
        
        return True


    def get_data(self):
        
        try:

            self.device.experiment_stop()

            exp_id = self.device.experiment_load(self.template, 'ThermalControlTest')
            self.device.experiment_start(exp_id)
            self.device.data_logger_start(10, 30000-10)

            self.logger_data = self.device.data_logger_trigger()
            self.device.data_logger_stop()
            
            if self.verbosity > 1:
                print("Finished collecting date while running experiment id %d"%exp_id)

            self.dump_data()

        finally:
            self.device.experiment_stop()


    def analyze_data(self):

        self.status = Status.PASS


    def result_table(self, _print=True):

        output = ''

        if _print:
            print(output)
        else:
            return output


import argparse
import pprint

tests_available = ['ChaiNoiseTest', 'ChaiThermalControlTest']
log_filename = 'chai_test.log'

def main():
    parser = argparse.ArgumentParser(description='Chai Device test script')
    parser.add_argument('device', 
            help="Device IP address or hostname")
    parser.add_argument('--email',
            help="User email")
    parser.add_argument('--password',
            help="User password")
    parser.add_argument('--ssh_user',
            help="ssh user")
    parser.add_argument('--ssh_password',
            help="ssh password")
    parser.add_argument('--verbosity', default = 2, choices = [0, 1, 2], type=int,
            help="Log and display verbosity (default = %(default)d)")
    parser.add_argument('--testlist', default = 'testlist.py',
            help="List of tests (default = %(default)s)")
    parser.add_argument('test', nargs='*', 
            help="Test name for running individual tests")

    args = parser.parse_args()

    logdir = 'out_' + args.device
    if os.path.exists(logdir):
        if os.path.isdir(logdir):
            shutil.rmtree(logdir)
        else:
            raise Exception('%s exists and is not a directory:'%logdir)
    os.makedirs(logdir)

    if args.testlist.endswith('.py'):
        tmp = args.testlist[:-3]
        try:
            test_list_mod = __import__(tmp)
        except ImportError:
            raise Exception("Failed to load test list from: " + args.testlist)
    else:
        raise Exception("Test list filename must have *.py extension")
    
    test_list = []
    for test_name, test_class_name, test_params in test_list_mod.test_list:
        if test_class_name in tests_available:
            test_list.append((
                    test_name,
                    eval(test_class_name),
                    test_params
                    ))
        else:
            raise Exception('Invalid test class name: ' + test_class_name)

    with open(os.path.join(logdir, log_filename), 'w') as log:

        log.write('Starting on ' + time.strftime('%c') + '\n')

        log.write('----------------------------\n')
        log.write('Command line arguments:\n\n')
        for arg in vars(args):
            log.write('%s = %s\n'%(arg, getattr(args, arg)))

        log.write('----------------------------\n')
        log.write('test_list =\n')
        pprint.pprint(test_list_mod.test_list, log)
        log.flush()
        os.fsync(log.fileno())

        test_name_list = [t[0] for t in test_list]
        if args.test:
            for t in args.test:
                if not t in test_name_list:
                    raise Exception('Unknown test name: %s'%t)
            active_tests = args.test
        else:
            active_tests = test_name_list


        device = remote.ChaiDevice(
                host = args.device, 
                email= args.email,
                passwd = args.password,
                ssh_user = args.ssh_user,
                ssh_passwd = args.ssh_password
                )

        results = []
        for test_name, test_class, test_params in test_list:
            if not test_name in active_tests:
                continue
            test = test_class(**test_params)
            test.device = device
            test.label = test_name
            test.verbosity = args.verbosity
            test.logfile = log
            test.logdir = logdir

            test.run()
            results.append((test_name, test.status))
            log.flush()
            os.fsync(log.fileno())

        util.tee('----------------------------\n', log)
        util.tee('Summary:\n', log)
        for test_name, result in results:
            print('%-20s %20s'%(test_name, status_string(result, '{:^8}')))
            log.write('%-20s %8s\n'%(test_name, status_string(result, '{:^8}', color=False)))
        print('Global status: %s'%status_string(max([r[1] for r in results]), '{:^8}'))
        log.write('Global status: %s\n'%status_string(max([r[1] for r in results]), '{:^8}', color=False))

        util.tee('----------------------------\n', log)
        print('Run details stored in directory "%s"'%logdir)
        util.tee('Completed on ' + time.strftime('%c') + '\n')


if __name__=='__main__':
    #try:
        sys.exit(main())
    #except Exception as e:
    #    print('Error: %s'%e.message)

