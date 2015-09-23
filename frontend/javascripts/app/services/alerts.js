window.ChaiBioTech.ngApp.service('alerts', [
  function() {

    return {
      noOfCyclesWarning: "The value you have entered is less than AUTO DELTA START CYCLE. Please enter a value greater than AUTO DELTA START CYCLE or reduce AUTO DELTA START CYCLE and re-enter value.",
      nonDigit: "You have entered a wrong value. Please make sure you enter digits.",
      autoDeltaOnWrongStage: "You can't turn on auto delta on this stage. Please select a CYCLING STAGE to enable auto delat.",
      startOnCycleWarning: "The value you have entered is greater than number of cycles set for this stage. Please enetr a value lower than number of cycles or Increase number of cycles for this stage.",
      startOnCycleMinimum: "The minimum value you can enter is 1 please input a value greater than zero.",
      rampSpeedWarning: "Please Enter a valid integer value less than 1000."
    };
  }
]);
