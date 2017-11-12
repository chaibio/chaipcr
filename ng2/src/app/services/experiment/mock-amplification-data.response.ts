
let getAmpliData = () => {

  let idata = ["channel", "well_number", "cycle_num", "background_subtracted_value", "baseline_subtracted_value"];

  let data: Array<Array<string | number>> = [idata];

  for (let ch=1; ch<=2; ch++) {
    for (let cycle=1; cycle <=20; cycle++) {
      for (let w=0; w < 16; w++) {
        data.push([
          ch,
          w,
          cycle,
          Math.round(Math.random() * 1000),
          Math.round(Math.random() * 1000),
        ]);
      }
    }
  }

  //make a less than 10 value sample
  data[1] = [1, 0, 1, 5, 5];

  return data;

}

let getCqData = () => {
  let data: Array<Array<string | number>> = [["channel", "well_num", "cq"]];

  for (let c=1; c<=2; c++) {
    for (let d=0; d < 100; d++) {
      for (let w=0; w < 15; w++) {
        data.push([
          c,
          Math.round(Math.random() * 1000),
          Math.round(Math.random() * 1000),
          null
        ]);
      }
    }
  }

  return data;

}

export const MockAmplificationDataResponse = {
  partial: true,
  steps: [
    {
      step_id: 1,
      amplification_data: getAmpliData(),
      cq: getCqData()
    }
  ]
}
