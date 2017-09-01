describe("Testing addStageService", function() {

    var _addStageService, _constants, _correctNumberingService, _stage, _circleManager;
    
    beforeEach(function() {
        module('ChaiBioTech', function($provide) {

            $provide.value('stage', function() {
                return {
                    updateStageData: function() {},
                    render: function() {}
                };
            });
        });

        
        inject(function($injector) {
            _addStageService = $injector.get('addStageService');
            _circleManager = $injector.get('circleManager');
            _constants = $injector.get('constants');
            _correctNumberingService = $injector.get('correctNumberingService');
            _stage = $injector.get('stage');
        });

    });
    

    it("It should test init method", function() {

        _addStageService.init("init");
        expect(_addStageService.canvasObj).toEqual("init");
    });

    it("It should test addNewStage method", function() {

        _addStageService.canvasObj = {
            $scope: {

            },
            allStageViews: {
                splice: function() {}
            }

        };

        var currentStage = {
            myWidth: 128,
            childSteps: [
                {
                    ordealStatus: 10
                }
            ]
        };

        var data = {
            stage: {
                steps: {
                    length: 2
                }
            }
        };

        spyOn(_addStageService, "makeSpaceForNewStage").and.returnValue({
            index: 1
        });

        spyOn(_addStageService, "addNextandPrevious").and.returnValue(true);
        spyOn(_addStageService, "insertStageGraphics").and.returnValue(true);
        _addStageService.addNewStage(data, currentStage, "yes");
        expect(_addStageService.insertStageGraphics).toHaveBeenCalled();
        expect(_addStageService.addNextandPrevious).toHaveBeenCalled();

    });
});