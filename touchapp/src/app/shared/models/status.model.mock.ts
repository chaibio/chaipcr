export const StatusDataMockInstance = {
  experiment_controller: {
    experiment: {
      id: 1,
      name: "Exp 1",
      estimated_duration: 12345,
      paused_duration: 30,
      run_duration: 123
    },
    machine: {
      state: "running",
      thermal_state: "running"
    }
  },
  heat_block: {
    zone1: {
      temperature: 123,
      target_temperature: 123,
      drive: 0
    },
    zone2: {
      temperature: 123,
      target_temperature: 1234,
      drive: 1
    },
    temperature: 123
  },
  lid: {
    temperature: 123,
    target_temperature: 1234,
    drive: 1
  },
  optics: {
    intensity: 1,
    collect_data: true,
    lid_open: false,
    well_number: 1,
    photodiode_value: [
      1
    ]
  },
  heat_sink: {
    temperature: 12,
    fan_drive: 20
  },
  device: {
    update_available: ""
  }
}
