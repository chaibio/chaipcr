describe("Testing movingStepGraphics service", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));
  beforeEach(module('canvasApp'));

  var _movingStepGraphics, currentStep;
  beforeEach(inject(function(movingStepGraphics) {

    _movingStepGraphics = movingStepGraphics;
    _movingStepGraphics.offset = 41;

    currentStep = {
      previousStep: {

      },
      parentStage: {
        myWidth: 128,
        left: 100,
        stageRect: {
          setWidth: function() {},
          setCoords: function() {}
        },
        roof: {
          setWidth: function() {},
          setCoords: function() {}
        },
        stageGroup: {
          left: 100,
          setLeft: function() {},
          setCoords: function() {}
        },
        dots: {
          left: 110,
          setLeft: function() {},
          setCoords: function() {}
        }
      }
    };
  }));

  it("It should test initiateMoveStepGraphics method", function() {

    spyOn(_movingStepGraphics, "arrangeStepsOfStage");
    spyOn(_movingStepGraphics, "setWidthOfStage");
    spyOn(_movingStepGraphics, "setLeftOfStage");

    _movingStepGraphics.initiateMoveStepGraphics(currentStep);

    expect(_movingStepGraphics.arrangeStepsOfStage).toHaveBeenCalled();
    expect(_movingStepGraphics.setWidthOfStage).toHaveBeenCalled();
    expect(_movingStepGraphics.setLeftOfStage).toHaveBeenCalled();
  });

  it("It should test setWidthOfStage method", function() {

    var preWidth = currentStep.parentStage.myWidth;

    spyOn(currentStep.parentStage.stageRect, "setWidth");
    spyOn(currentStep.parentStage.stageRect, "setCoords");

    spyOn(currentStep.parentStage.roof, "setWidth");
    spyOn(currentStep.parentStage.roof, "setCoords");

    spyOn(currentStep.parentStage.stageGroup, "setLeft");
    spyOn(currentStep.parentStage.stageGroup, "setCoords");

    spyOn(currentStep.parentStage.dots, "setLeft");
    spyOn(currentStep.parentStage.dots, "setCoords");

    _movingStepGraphics.setWidthOfStage(currentStep.parentStage);

    expect(currentStep.parentStage.myWidth).toEqual(preWidth - 75);

    expect(currentStep.parentStage.stageRect.setWidth).toHaveBeenCalled();
    expect(currentStep.parentStage.stageRect.setCoords).toHaveBeenCalled();

    expect(currentStep.parentStage.roof.setWidth).toHaveBeenCalled();
    expect(currentStep.parentStage.roof.setCoords).toHaveBeenCalled();

    expect(currentStep.parentStage.stageGroup.setLeft).toHaveBeenCalled();
    expect(currentStep.parentStage.stageGroup.setCoords).toHaveBeenCalled();

    expect(currentStep.parentStage.dots.setLeft).toHaveBeenCalled();
    expect(currentStep.parentStage.dots.setCoords).toHaveBeenCalled();
  });

  it("It should test setLeftOfStage method", function() {

    var preLeft = currentStep.parentStage.left;
    _movingStepGraphics.setLeftOfStage(currentStep.parentStage);
    expect(currentStep.parentStage.left).toEqual(preLeft + _movingStepGraphics.offset);
  });

  it("It should test moveLittleRight method", function() {
    var step = {
      left: 100,
      moveStep: function() {},
      circle: {
        moveCircleWithStep: function() {},
      }
    };

    spyOn(step, "moveStep");
    spyOn(step.circle, "moveCircleWithStep");

    _movingStepGraphics.moveLittleRight(step);

    expect(step.left).toEqual(141);
    expect(step.moveStep).toHaveBeenCalled();
    expect(step.circle.moveCircleWithStep).toHaveBeenCalled();
  });

  it("It should test moveLittleLeft method", function() {

    var step = {
      left: 100,
      moveStep: function() {},
      circle: {
        moveCircleWithStep: function() {},
      }
    };

    spyOn(step, "moveStep");
    spyOn(step.circle, "moveCircleWithStep");

    _movingStepGraphics.moveLittleLeft(step);

    expect(step.left).toEqual(18);
    expect(step.moveStep).toHaveBeenCalled();
    expect(step.circle.moveCircleWithStep).toHaveBeenCalled();

  });


  it("It should test arrangeStepsOfStage method", function() {

    var step = {
      previousStep: {

      },
      nextStep: {

      },
      left: 100,
      moveStep: function() {},
      circle: {
        moveCircleWithStep: function() {},
      }
    };

    spyOn(_movingStepGraphics, "moveLittleLeft");
    spyOn(_movingStepGraphics, "moveLittleRight");

    _movingStepGraphics.arrangeStepsOfStage(step);

    expect(_movingStepGraphics.moveLittleLeft).toHaveBeenCalled();
    //expect(_movingStepGraphics.moveLittleRight).toHaveBeenCalled();
  });
});
