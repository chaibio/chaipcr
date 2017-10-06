describe("Testing circle", function() {

    var _Constants, _circleGroup, _outerCircle, _centerCircle, _littleCircleGroup, _circleMaker, 
    _gatherDataGroupOnScroll, _gatherDataCircleOnScroll, _gatherDataGroup, _gatherDataCircle, _previouslySelected,
    _pauseStepOnScrollGroup, _pauseStepCircleOnScroll, _pauseStepService, _editModeService, _stepDataGroupService, _circle, circle;

    beforeEach(function() {
    
        module("ChaiBioTech", function ($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _Constants = $injector.get('constants');
            _circleGroup = $injector.get('circleGroup');
            _outerCircle = $injector.get('outerCircle');
            _centerCircle = $injector.get('centerCircle');
            _littleCircleGroup = $injector.get('littleCircleGroup');
            _circleMaker = $injector.get('circleMaker');
            _gatherDataGroupOnScroll = $injector.get('gatherDataGroupOnScroll');
            _gatherDataGroup = $injector.get('gatherDataGroup');
            _gatherDataCircle = $injector.get('gatherDataCircle');
            _previouslySelected = $injector.get('previouslySelected');
            _pauseStepOnScrollGroup = $injector.get('pauseStepOnScrollGroup');
            _pauseStepCircleOnScroll = $injector.get('pauseStepCircleOnScroll');
            _pauseStepService = $injector.get('pauseStepService');
            _stepDataGroupService = $injector.get('stepDataGroupService');
            _circle = $injector.get('circle');
            _editModeService = $injector.get('editModeService');
        
        });
        
    });

    it("It should test getLeft method", function() {

        var model = {};

        var parentStep = {
            left: 100,
            canvas: {}
        };

        var $scope = {};

        circle = new _circle(model, parentStep, $scope);
        var retVal = circle.getLeft();
        expect(retVal.left).toEqual(100);
    });

    it("It sould test moveCircle method", function() {

        var model = {};

        var parentStep = {
            left: 100,
            canvas: {}
        };

        var $scope = {};

        circle = new _circle(model, parentStep, $scope);

        spyOn(circle, "getLeft").and.returnValue(100);
        spyOn(circle, "getTop").and.returnValue(40);

        circle.moveCircle();

        expect(circle.getLeft).toHaveBeenCalled();
        expect(circle.getTop).toHaveBeenCalled();
    });

    it("It should test setCenter method", function() {

        var model = {};

        var parentStep = {
            left: 100,
            canvas: {}
        };

        var $scope = {};

        circle = new _circle(model, parentStep, $scope);

        var imgObj = {

        };
        circle.setCenter(imgObj);

        expect(imgObj.originX).toEqual("center");
        expect(imgObj.originY).toEqual("center");
    });
  
});