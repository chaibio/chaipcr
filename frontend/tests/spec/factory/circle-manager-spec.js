describe("Testing circleManager", function() {

    var _circleManager, _path, _moveRampLineService;

    beforeEach(function() {

        module("ChaiBioTech", function ($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('path', function() {
                return {
                    path: "done",
                };
            });
        });

        inject(function($injector) {
            _circleManager = $injector.get('circleManager');
            _path = $injector.get('path');
            _moveRampLineService = $injector.get('moveRampLineService');
        });
    });

    it("It should test init method", function() {

        var kanvas = {
            status: "TESTING",
            allStepViews: "ALL STEPS",
            allCircles: "ALL CIRCLES",
            findAllCirclesArray: "FIND ALL CIRCLES",
            drawCirclesArray: "DRAW CIRCLES ARRAY",
            canvas: "CANVAS"
        };

        _circleManager.init(kanvas);

        expect(_circleManager.originalCanvas.status).toEqual("TESTING");
        expect(_circleManager.allStepViews).toEqual("ALL STEPS");
        expect(_circleManager.allCircles).toEqual("ALL CIRCLES");
        expect(_circleManager.findAllCirclesArray).toEqual("FIND ALL CIRCLES");
        expect(_circleManager.drawCirclesArray).toEqual("DRAW CIRCLES ARRAY");
        expect(_circleManager.canvas).toEqual("CANVAS");
    });

    it("It should test togglePaths method", function() {

        _circleManager.originalCanvas = {
            allStepViews: [
                {
                    circle: {
                        curve: {
                            setVisible: function(toggle) {}
                        }
                    }
                   
                },
                {
                    circle: {

                    }
                }
            ]
        };

        spyOn(_circleManager.originalCanvas.allStepViews[0].circle.curve, "setVisible");

        _circleManager.togglePaths(true);

        expect(_circleManager.originalCanvas.allStepViews[0].circle.curve.setVisible).toHaveBeenCalled();
    });

    it("it should test addRampLinesAndCircles method", function() {

        var circles = [
            {
                moveCircle: function() {},
                getCircle: function() {},
                parent: {
                    rampSpeedGroup: {}
                }
            },
            {
                moveCircle: function() {},
                getCircle: function() {},
                parent: {
                    rampSpeedGroup: {}
                }
            },
            {
                moveCircle: function() {},
                getCircle: function() {},
                parent: {
                    rampSpeedGroup: {}
                },
                doThingsForLast: function() {},
            },

        ];

        _circleManager.originalCanvas = {};
        _circleManager.canvas = {
            add: function() {},
            bringToFront: function() {},
        };
        
        spyOn(circles[0] ,"moveCircle");
        spyOn(circles[0], "getCircle");
        spyOn(circles[2], "doThingsForLast");
        spyOn(_circleManager.canvas, "add");
        spyOn(_circleManager.canvas, "bringToFront");

        _circleManager.addRampLinesAndCircles(circles);
        
        expect(circles[0].moveCircle).toHaveBeenCalled();
        expect(circles[0].getCircle).toHaveBeenCalled();
        expect(circles[2].doThingsForLast).toHaveBeenCalled();

        expect(_circleManager.canvas.add).toHaveBeenCalled();
        expect(_circleManager.canvas.bringToFront).toHaveBeenCalled();
    });


    it("It should test addRampLines method", function() {

        _circleManager.canvas = {
            add: function() {},
            bringToFront: function() {},
            renderAll: function() {}
        };

        _circleManager.originalCanvas = {
            allStepViews: [
                {
                    model: {
                        ramp: 10
                    },
                    circle: {
                        circleGroup: {},
                        moveCircleWithStep: function() {},
                        gatherDataDuringRampGroup: {},
                        //curve: {
                            //setVisible: function() {},
                        //}
                    }
                },
                {
                    model: {
                        ramp: {
                            collect_data: true
                        }
                    },
                    circle: {
                        circleGroup: {},
                        moveCircleWithStep: function() {},
                        gatherDataDuringRampGroup: {
                            setVisible: function() {},
                        },
                        curve: {
                            setVisible: function() {},
                        }
                    }
                },
                {
                    model: {
                        ramp: 10
                    },
                    circle: {
                        circleGroup: {},
                        moveCircleWithStep: function() {},
                        gatherDataDuringRampGroup: {},
                        curve: {
                            setVisible: function() {},
                        }
                    }
                }
            ]
        };
        spyOn(_moveRampLineService, "manageDrag").and.returnValue(true);
        spyOn(_circleManager.canvas, "add");
        spyOn(_circleManager.canvas, "bringToFront");
        spyOn(_circleManager.canvas, "renderAll");

        spyOn(_circleManager.originalCanvas.allStepViews[1].circle.gatherDataDuringRampGroup, "setVisible");

        _circleManager.addRampLines();

        expect(_moveRampLineService.manageDrag).toHaveBeenCalled();
        expect(_circleManager.canvas.add).toHaveBeenCalled();
        expect(_circleManager.canvas.bringToFront).toHaveBeenCalled();
        expect(_circleManager.canvas.renderAll).toHaveBeenCalled();
        expect(_circleManager.originalCanvas.allStepViews[1].circle.gatherDataDuringRampGroup.setVisible).toHaveBeenCalled();
    });
});