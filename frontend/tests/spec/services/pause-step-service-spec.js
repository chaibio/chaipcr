describe("Testing pauseStepService", function() {
    
    var _pauseStepService;
    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {
            _pauseStepService = $injector.get('pauseStepService');
        });

    });

    it("It should test applyPauseChanges method", function() {

        var circleGroup = {

            circle: {
                setFill: function() {},
                setStroke: function() {},
                strokeWidth: 0,
                radius: 0
            },
            pauseImageMiddle: {
                setVisible: function() {},
            },
            gatherDataImageMiddle: {
                setVisible: function() {},
            },
            pauseStepOnScrollGroup: {
                setVisible: function() {},
            }
        };

        spyOn(circleGroup.circle, "setFill");
        spyOn(circleGroup.circle, "setStroke");
        spyOn(circleGroup.pauseImageMiddle, "setVisible");
        spyOn(circleGroup.gatherDataImageMiddle, "setVisible");
        spyOn(circleGroup.pauseStepOnScrollGroup, "setVisible");

        _pauseStepService.applyPauseChanges(circleGroup);

        expect(circleGroup.circle.setFill).toHaveBeenCalled();
        expect(circleGroup.circle.setStroke).toHaveBeenCalled();
        expect(circleGroup.pauseImageMiddle.setVisible).toHaveBeenCalled();
        expect(circleGroup.gatherDataImageMiddle.setVisible).toHaveBeenCalled();
        expect(circleGroup.pauseStepOnScrollGroup.setVisible).toHaveBeenCalled();

        expect(circleGroup.circle.strokeWidth).toEqual(4);
        expect(circleGroup.circle.radius).toEqual(13);
    });

    it("It should test controlPause method, when state && circleGroup.big", function() {

        var circleGroup = {
            model: {
                pause: true
            },
            big: true,
            pauseStepOnScrollGroup: {
                setVisible: function() {},
            },
            holdTime: {
                setVisible: function() {}
            }
        };

        spyOn(circleGroup.pauseStepOnScrollGroup, "setVisible");
        spyOn(circleGroup.holdTime, "setVisible");

        _pauseStepService.controlPause(circleGroup);

        expect(circleGroup.pauseStepOnScrollGroup.setVisible).toHaveBeenCalled();
        expect(circleGroup.holdTime.setVisible).toHaveBeenCalled();
    });

    it("It should test controlPause method, when state is true", function() {

        var circleGroup = {
            model: {
                pause: true
            },
            big: false,
            pauseStepOnScrollGroup: {
                setVisible: function() {},
            },
            holdTime: {
                setVisible: function() {}
            }
        };

        spyOn(circleGroup.holdTime, "setVisible");
        spyOn(_pauseStepService, "applyPauseChanges").and.returnValue(true);
        _pauseStepService.controlPause(circleGroup);

        expect(circleGroup.holdTime.setVisible).toHaveBeenCalled();
        expect(_pauseStepService.applyPauseChanges).toHaveBeenCalled();
    });

    it("It should test controlPause method, when state is false", function() {

        var circleGroup = {
            model: {
                pause: false
            },
            big: false,
            pauseStepOnScrollGroup: {
                setVisible: function() {},
            },
            holdTime: {
                setVisible: function() {}
            }
        };

        spyOn(circleGroup.pauseStepOnScrollGroup, "setVisible");
        spyOn(circleGroup.holdTime, "setVisible");

        _pauseStepService.controlPause(circleGroup);

        expect(circleGroup.pauseStepOnScrollGroup.setVisible).toHaveBeenCalledWith(false);
        expect(circleGroup.holdTime.setVisible).toHaveBeenCalledWith(true);
    });

});