export interface Ramp {
  id: number,
  rate: number,
  collect_data: boolean
}

export interface Step {
  id: number,
  name: string,
  order_number: number,
  pause: boolean,
  temperature: number,
  collect_data: boolean,
  delta_duration_s: number,
  delta_temperature: number,
  hold_time: number,
  ramp: Ramp
}

export interface Stage {
  id: number,
  name: string,
  num_cycles: number,
  order_number: number,
  stage_type: string
  auto_delta: boolean,
  auto_delta_start_cycle: number,
  steps: Array<Step>
}

export interface Protocol {
  id: number,
  estimate_duration: number,
  lid_temperature: number,
  stages: Array<Stage>
}

export interface Experiment {
  id: number,
  name: string,
  type: string,
  time_valid: boolean,
  started_at: string,
  created_at: string,
  completed_at: string,
  completion_status: string,
  completion_message: string,
  protocol: Protocol
}
