export interface StatusData {
  experiment_controller: {
    experiment: {
      id: number,
      name: string,
      estimated_duration: number,
      paused_duration: number,
      run_duration: number
    },
    machine: {
      state: string,
      thermal_state: string
    }
  },
  heat_block: {
    zone1: {
      temperature: number,
      target_temperature: number,
      drive: number
    },
    zone2: {
      temperature: number,
      target_temperature: number,
      drive: number
    },
    temperature: number
  },
  lid: {
    temperature: number,
    target_temperature: number,
    drive: number
  },
  optics: {
    intensity: number,
    collect_data: boolean,
    lid_open: boolean,
    well_number: number,
    photodiode_value: Array<number>
  },
  heat_sink: {
    temperature: number,
    fan_drive: number
  },
  device: {
    update_available: string
  }
}
