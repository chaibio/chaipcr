window.ChaiBioTech.ngApp.factory('constants', [
  function() {
    var originalStepHeight = 200, tempBarHeight = 18;
    return {
      "stepHeight": originalStepHeight - tempBarHeight,
      "stepUnitMovement": (originalStepHeight - tempBarHeight) / 100, //No more used
      "stepWidth": 128,
      "tempBarWidth": 45,
      "tempBarHeight": tempBarHeight,
      "beginningTemp": 25,
      "originalStepHeight": originalStepHeight,
      "rad2deg": 180 / Math.PI,
      "controlDistance": 50,
      "canvasSpacingFrontAndRear": 33,
      "newStageOffset": 8,
      "additionalWidth": 2
    };
  }
]);
