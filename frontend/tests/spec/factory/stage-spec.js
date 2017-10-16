describe("Testing stage factory", function() {

    var stage, _stage,  _step, _previouslySelected, _stageGraphics, _constants, _correctNumberingService, 
    _addStepService, _deleteStepService, _moveStageToSides;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            $provide.value('IsTouchScreen', function () {});

        });

        inject(function($injector) {

            _step = $injector.get('step');
            _stage = $injector.get('stage');
            _previouslySelected = $injector.get('previouslySelected');
            _stageGraphics = $injector.get('stageGraphics');
            _constants = $injector.get('constants');
            _correctNumberingService = $injector.get('correctNumberingService');
            _addStepService = $injector.get('addStepService');
            _deleteStepService = $injector.get('deleteStepService');
            _moveStageToSides = $injector.get('moveStageToSides');  
        });

        var model = {
            steps: [
                {

                },
                {

                }
            ]
        };

        var kanvas = {
            name: "ChaiKanvas",
            canvas: {
                renderAll: function() {}
            }
        };

        var index = 1;

        var insert = false;

        $scope = {

        };

        stage = new _stage(model, kanvas, index, insert, $scope);

    });

    it("It should test initial values of stage", function() {

        expect(stage.model.steps.length).toEqual(2);
        expect(stage.index).toEqual(1);
        expect(stage.canvas.renderAll).toEqual(jasmine.any(Function));
        expect(stage.myWidth).toEqual(258);
        expect(stage.parent.name).toEqual("ChaiKanvas");
        expect(stage.childSteps).toEqual(jasmine.any(Array));
        expect(stage.nextStage).toEqual(null);
        expect(stage.previousStage).toEqual(null);
        expect(stage.noOfCycles).toEqual(null);
        expect(stage.insertMode).toEqual(false);
        expect(stage.shrinked).toEqual(false);
        expect(stage.shadowText).toEqual("0px 1px 2px rgba(0, 0, 0, 0.5)");
        expect(stage.visualComponents).toEqual(jasmine.any(Object));
        expect(stage.stageMovedDirection).toEqual(null);
        expect(stage.shortStageName).toEqual(false);
        expect(stage.shrinkedStage).toEqual(false);
        expect(stage.sourceStage).toEqual(false);
        expect(stage.moveStepAction).toEqual(null);
    });

    it("It should test setNewWidth method", function() {
        
        stage.myWidth = 100;
        var add = 50;
        spyOn(stage, "setWidth").and.returnValue(true);
        stage.setNewWidth(50);
        expect(stage.myWidth).toEqual(150);
        expect(stage.setWidth).toHaveBeenCalled();
    });
});