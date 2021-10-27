import { StatusData } from '../../shared/models/status.model'

export const initialStatusData: StatusData = {
  experiment_controller: {
    experiment: {
      id: null,
      name: null,
      estimated_duration: null,
      paused_duration: null,
      run_duration: null 
    },
    machine: {
      state: '',
      thermal_state: ''
    }
  },
  heat_block: {
    zone1: {
      temperature: 0,
      target_temperature: 0,
      drive: 0
    },
    zone2: {
      temperature: 0,
      target_temperature: 0,
      drive: 0
    },
    temperature: 0
  },
  lid: {
    temperature: 0,
    target_temperature: 0,
    drive: 0
  },
  optics: {
    intensity: 0,
    collect_data: false,
    lid_open: false,
    well_number: 0,
    photodiode_value: [
      0
    ]
  },
  heat_sink: {
    temperature: 0,
    fan_drive: 0
  },
  device: {
    update_available: ''
  }
}
