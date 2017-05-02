function DeviceInfoMock() {
  this.$remove = function(fn) {
    fn()
  }
}

DeviceInfoMock.getInfo = function(no) {
  return {
    then: function(fn) {
      fn({
        data: {
            "experiment_controller": {
                "machine": {
                    "state": "idle",
                    "thermal_state": "idle"
                }
            },
            "heat_block": {
                "zone1": {
                    "temperature": "29.1369991",
                    "target_temperature": "0",
                    "drive": "-0"
                },
                "zone2": {
                    "temperature": "29.2019997",
                    "target_temperature": "0",
                    "drive": "-0"
                },
                "temperature": "29.1690006"
            },
            "lid": {
                "temperature": "29.3980007",
                "target_temperature": "0",
                "drive": "0"
            },
            "optics": {
                "intensity": "60",
                "collect_data": "false",
                "lid_open": "false",
                "well_number": "0",
                "photodiode_value": [
                    "634",
                    "1204"
                ]
            },
            "heat_sink": {
                "temperature": "29.2870007",
                "fan_drive": "0"
            },
            "device": {
                "update_available": "available"
            }
        }
      })
    }
  }
}
