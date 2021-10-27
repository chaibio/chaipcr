import { AmplificationDatum } from './amplification-datum.model';

export interface AmplificationData {
  channel_1: AmplificationDatum[],
  channel_2: AmplificationDatum[]
}
