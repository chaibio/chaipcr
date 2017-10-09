describe("Testing canvas.js", function() {

  var Canvas, _events, _stage, _path, _stageEvents, _stepEvents, _moveStepRect, _moveStageRect, _constants,
  _circleManager, _dots, _StagePositionService, _StepPositionService, _Line, _correctNumberingService,
  _editModeService, _addStageService, _loadImageService;

  beforeEach(function() {
    
    module("ChaiBioTech", function ($provide) {
      $provide.value('IsTouchScreen', function () {});
      $provide.value('stage', function() {
        return {
          created: "yes",
          render: function() {}
        };
      });
      $provide.value('Group', {
        create: function() {
          return {
            alright: "yes"
          };
        }
      });
    });

    inject(function($injector) {

      Canvas = $injector.get('canvas');
      _events = $injector.get('events');
      _stage = $injector.get('stage');
      _path = $injector.get('path');
      _stageEvents = $injector.get('stageEvents');
      _stepEvents = $injector.get('stepEvents');
      _moveStepRect = $injector.get('moveStepRect');
      _moveStageRect = $injector.get('moveStageRect');
      _constants = $injector.get('constants');
      _circleManager = $injector.get('circleManager');
      _dots = $injector.get('dots');
      _StagePositionService = $injector.get('StagePositionService');
      _StepPositionService = $injector.get('StepPositionService');
      _Line = $injector.get('Line');
      _Group = $injector.get('Group');
      _correctNumberingService = $injector.get('correctNumberingService');
      _editModeService = $injector.get('editModeService');
      _addStageService = $injector.get('addStageService');
      _loadImageService = $injector.get('loadImageService');

    });

  });
  
  it("canvas.init should initiate values", function() {
    
    var model = {
      "protocol": {

      }
    };
    
    spyOn(Canvas, "loadImages");
    Canvas.init(model);

    expect(Canvas.editStageStatus).toBeFalsy();
    expect(Canvas.allCircles).toBeNull();

    expect(Canvas.images).toContain("gather-data.png");
    expect(Canvas.images).toContain("gather-data-image.png");
    expect(Canvas.images).toContain("pause.png");
    expect(Canvas.images).toContain("pause-middle.png");
    expect(Canvas.images).toContain("drag-footer-image.png");
    expect(Canvas.images).toContain("move-step-on.png");

    expect(Canvas.imageLocation).toEqual('/images/');
    expect(Canvas.canvas).not.toBeNull();
    expect(Canvas.moveLimit).toEqual(0);

    expect(Canvas.imageobjects).toEqual(jasmine.any(Object));
    expect(Canvas.dotCordiantes).toEqual(jasmine.any(Object));

    expect(Canvas.loadImages).toHaveBeenCalled();
  });

  it("setDefaultWidthHeight method should set the width of the canvas", function() {

    var model = {
      "protocol": {

      }
    };
    
    spyOn(Canvas, "loadImages");
    Canvas.init(model);

    spyOn(Canvas.canvas, "setHeight");
    spyOn(Canvas.canvas, "renderAll");
    spyOn(Canvas.canvas, "setWidth");

    Canvas.setDefaultWidthHeight();
    expect(Canvas.canvas.setHeight).toHaveBeenCalledWith(400);
    expect(Canvas.canvas.renderAll).toHaveBeenCalled();
    expect(Canvas.canvas.setWidth).toHaveBeenCalled();
    expect(Canvas.allStageViews.length).toEqual(jasmine.any(Number));
  });

  it("It should test addStages method", function() {

    Canvas.model = {
      
        protocol: {
          stages: [
            {index: 1},
            {index: 2},
            {index: 3}
          ]
        }
      
    };

    spyOn(Canvas, "addStagesMapCallback").and.returnValue(true);
    spyOn(_StagePositionService, "init").and.returnValue(true);
    spyOn(_StepPositionService, "init").and.returnValue(true);
    
    Canvas.addStages();

    expect(Canvas.addStagesMapCallback).toHaveBeenCalled();
    expect(_StagePositionService.init).toHaveBeenCalled();
    expect(_StepPositionService.init).toHaveBeenCalled();

  });

  it("It should test addStagesMapCallback method", function() {

    var stageData = {
      stage: {
        model: {
          id: 10
        }
      }
    };

    var index = 3;
    Canvas.tempPreviousStage = { exist: true };
    Canvas.$scope = {

    };
    
    var retVal = Canvas.addStagesMapCallback(stageData, index);
    expect(Canvas.tempPreviousStage.created).toEqual("yes");
    expect(retVal.created).toEqual("yes");

  });

  it("It should test addStagesMapCallback method, when tempPreviousStage is not defined", function() {

    var stageData = {
      stage: {
        model: {
          id: 10
        }
      }
    };

    var index = 3;
    
    Canvas.$scope = {

    };
    
    var retVal = Canvas.addStagesMapCallback(stageData, index);
    expect(Canvas.tempPreviousStage.created).toEqual("yes");
    expect(retVal.created).toEqual("yes");

  });

  it("It should test selectStep method", function() {

    Canvas.allStepViews = [
      { 
        ready: "yes",
        circle: {
          manageClick: function() {}
        }
      }
    ];

    Canvas.$scope = {};
    spyOn(Canvas.allStepViews[0].circle, "manageClick");
    Canvas.selectStep();
    expect(Canvas.allStepViews[0].circle.manageClick).toHaveBeenCalled();
    expect(Canvas.$scope.fabricStep.ready).toEqual("yes");
  });

  it("It should test initEvents method", function() {

    spyOn(_stageEvents, "init").and.returnValue(true);
    spyOn(_stepEvents, "init").and.returnValue(true);

    Canvas.initEvents();
    expect(_stageEvents.init).toHaveBeenCalled();
    expect(_stepEvents.init).toHaveBeenCalled();
  });

  it("It should test getComponents method", function() {

    Canvas.stageIndicator = { verticalLine: "stage verticalLine" };
    Canvas.stepIndicator = { verticalLine: "step verticalLine" };

    spyOn(Canvas, "getMoveDots").and.returnValue("dots");
    spyOn(_moveStageRect, "getMoveStageRect").and.returnValue(true);
    spyOn(_moveStepRect, "getMoveStepRect").and.returnValue(true);

    Canvas.getComponents();
    
    expect(Canvas.getMoveDots).toHaveBeenCalled();
    expect(_moveStepRect.getMoveStepRect).toHaveBeenCalled();
    expect(_moveStageRect.getMoveStageRect).toHaveBeenCalled();
    expect(Canvas.moveDots).toEqual("dots");
  });

  it("It should test addComponentsToStage", function() {

    Canvas.canvas = {
      add: function() {

      }
    };

    spyOn(Canvas.canvas, "add");

    Canvas.addComponentsToStage();
    expect(Canvas.canvas.add).toHaveBeenCalledTimes(5);
  });

  it("It should test getMoveDots method", function() {

    spyOn(_dots, "stepStageMoveDots").and.returnValue([]);
    Canvas.imageobjects = ["move-step-on.png"];
    
    Canvas.imageobjects["move-step-on.png"] = {
      setTop: function() {},
      setLeft: function() {},
    };

    var retVal = Canvas.getMoveDots();
    
    expect(_dots.stepStageMoveDots).toHaveBeenCalled();
    expect(retVal.alright).toEqual("yes");
    
  });

  it("It should test loadImages method", function() {

    Canvas.canvas = {
      fire: function() {}
    };
    spyOn(Canvas.canvas, "fire");
    spyOn(_loadImageService, "getImages").and.returnValue({
      then: function(callBack) {
        var iData = {
          imageLoaded: true
        };
        callBack(iData);
      }
    });

    
    Canvas.loadImages();
    expect(Canvas.canvas.fire).toHaveBeenCalled();
    expect(Canvas.imageobjects.imageLoaded).toEqual(true);
  });
});
