import { StatusData } from '../../shared/models/status.model'

export const initialStatusData: StatusData = {
  experiment_controller: {
    experiment: {
      id: -1,
      name: '',
      estimated_duration: 0,
      paused_duration: 0,
      run_duration: 0
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
