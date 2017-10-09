export const mockExperimentResponse = {
  "experiment":
  {
    "id":26,
    "name":"Test",
    "time_valid":true,
    "started_at":"2017-08-30T16:30:13.000Z",
    "completed_at":"2017-08-30T16:39:13.000Z",
    "completion_status":"aborted",
    "completion_message":"",
    "created_at":"2017-08-30T16:30:08.000Z",
    "type":"user",
    "protocol":{"id":31,
      "lid_temperature":"110.0",
      "estimate_duration":1050,
      "stages":[{"stage":{"id":56,
        "stage_type":"holding",
        "name":"Holding Stage",
        "num_cycles":1,
        "auto_delta":false,
        "auto_delta_start_cycle":1,
        "order_number":0,
        "steps":[{"step":{"id":107,
          "name":"Initial Denaturing",
          "temperature":"95.0",
          "hold_time":180,
          "pause":false,
          "collect_data":false,
          "delta_temperature":"0.0",
          "delta_duration_s":0,
          "order_number":0,
          "ramp":{"id":107,
            "rate":"1.0",
            "collect_data":false}

        }
        }
        ]}
      }
        ,{"stage":{"id":57,
          "stage_type":"cycling",
          "name":"Cycling Stage",
          "num_cycles":5,
          "auto_delta":false,
          "auto_delta_start_cycle":1,
          "order_number":1,
          "steps":[{"step":{"id":108,
            "name":"Denature",
            "temperature":"95.0",
            "hold_time":30,
            "pause":false,
            "collect_data":false,
            "delta_temperature":"0.0",
            "delta_duration_s":0,
            "order_number":0,
            "ramp":{"id":108,
              "rate":"1.0",
              "collect_data":false}

          }
          }
            ,{"step":{"id":109,
              "name":"Anneal",
              "temperature":"40.0",
              "hold_time":30,
              "pause":false,
              "collect_data":true,
              "delta_temperature":"0.0",
              "delta_duration_s":0,
              "order_number":1,
              "ramp":{"id":109,
                "rate":"1.0",
                "collect_data":false}

            }
            }
          ]}
        }
      ]}
  }
}

