describe("Testing events factory", function() {

   var eventSystem, _previouslySelected, _mouseOver, _mouseOut, _mouseDown, _objectMoving, _objectModified, _mouseMove, 
   _mouseUp, _htmlEvents, _circleManager, _textChanged, C, $scope;

   beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('mouseOver', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('mouseOver', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('mouseOut', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('mouseDown', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('objectMoving', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('objectModified', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('mouseMove', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('mouseUp', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('htmlEvents', {
                init: function() {
                    //console.log("Hiya");
                }
            });

            $provide.value('textChanged', {
                init: function() {
                    //console.log("Hiya");
                }
            });

        });

        inject(function($injector) {

            events = $injector.get('events');
            _previouslySelected = $injector.get('previouslySelected');
            _mouseOver = $injector.get("mouseOver");
            _mouseOut = $injector.get('mouseOut');
            _mouseDown = $injector.get('mouseDown');
            _objectMoving = $injector.get('objectMoving');
            _objectModified = $injector.get('objectModified');
            _mouseMove = $injector.get('mouseMove');
            _mouseUp = $injector.get('mouseUp');
            _htmlEvents = $injector.get('htmlEvents');
            _circleManager = $injector.get('circleManager');
            _textChanged = $injector.get('textChanged');

            C = {
                allStageViews: [
                    {
                        index: 1
                    }
                ],
                allStepViews: [
                    {
                        left: 180,
                    circle: {
                        holdTime: {
                            text: "∞"
                        }
                    }
                    }
                ],
                canvas: {
                    on: function() {

                    },
                    renderAll: function() {}
                }
            };

            $scope = {
                $apply: function(callback) {
                    callback();
                },
                summaryMode: null,
                applyValuesFromOutSide: function() {}
            };

            eventSystem = new events(C, $scope);
            
        });

   });

    it("It should test initial status", function() {

        expect(eventSystem.startDrag).toEqual(0);
        expect(eventSystem.mouseDown).toEqual(false);
        expect(eventSystem.mouseDownPos).toEqual(0);
        expect(eventSystem.mouseUpPos).toEqual(0);
        expect(eventSystem.moveStepActive).toEqual(false);
        expect(eventSystem.moveStageActive).toEqual(false);
    });

    it("It should test setSummaryMode method", function() {

        _previouslySelected.circle = {
            makeItSmall: function() {},
            parent: {
                unSelectStep: function() {},
                parentStage: {
                    unSelectStage: function() {}
                }
            }
        };

        spyOn($scope, "$apply").and.callThrough();
        spyOn(_previouslySelected.circle.parent.parentStage, "unSelectStage");
        spyOn(_previouslySelected.circle.parent, "unSelectStep");
        spyOn(_previouslySelected.circle, "makeItSmall");
        spyOn(C.canvas, "renderAll");

        eventSystem.setSummaryMode();

        expect($scope.summaryMode).toEqual(true);
        expect($scope.$apply).toHaveBeenCalled();
        expect(_previouslySelected.circle.parent.parentStage.unSelectStage).toHaveBeenCalled();
        expect(_previouslySelected.circle.parent.unSelectStep).toHaveBeenCalled();
        expect(_previouslySelected.circle.makeItSmall).toHaveBeenCalled();
        expect(C.canvas.renderAll).toHaveBeenCalled();

    });

    it("It should test selectStep method", function() {
        
        var circle = {
            manageClick: function() {}
        };

        spyOn(circle, "manageClick");
        spyOn($scope, "applyValuesFromOutSide");
        
        eventSystem.selectStep(circle);

        expect($scope.summaryMode).toEqual(false);
        expect(circle.manageClick).toHaveBeenCalled();
        expect($scope.applyValuesFromOutSide).toHaveBeenCalled();

    });

    describe("Testing containInfiniteStep method and different scenarios", function() {

        it("It should test when the passed step has nextStep", function() {

            var step = {
                parentStage: {
                    next: {

                    }
                }
            };

            var retVal = eventSystem.containInfiniteStep(step);

            expect(retVal).toEqual(false);
        });

        it("It should test when stage has no next", function() {

            var step = {
                parentStage: {
                    next: null,
                    childSteps: [
                        {
                            circle: {
                                holdTime: {
                                    text: "∞"
                                }
                            }
                        }
                    ]
                }
            };

            var retVal = eventSystem.containInfiniteStep(step);

            expect(retVal).toEqual(true);
        });

        it("It should test when holdTime.text !== '∞'", function() {

            var step = {
                parentStage: {
                    next: null,
                    childSteps: [
                        {
                            circle: {
                                holdTime: {
                                    text: "7"
                                }
                            }
                        }
                    ]
                }
            };

            var retVal = eventSystem.containInfiniteStep(step);

            expect(retVal).toEqual(false);
        });
    });

    describe("Testing infiniteStep method", function() {

        it("It should test infiniteStep method when holdTime.text === ∞", function() {
            var step = {
                circle: {
                    holdTime: {
                        text: "∞"
                    }
                }
            };

            var retVal = eventSystem.infiniteStep(step);

            expect(retVal).toEqual(true);
        });

        it("It should test infiniteStep method when holdTime.text !== ∞", function() {

            var step = {
                circle: {
                    holdTime: {
                        text: "hey"
                    }
                }
            };

            var retVal = eventSystem.infiniteStep(step);

            expect(retVal).toEqual(false);
        });
        
    });

    it("It should test calculateMoveLimitforStage method", function() {

        eventSystem.calculateMoveLimitforStage();
    });

    describe("It should test different aspects of calculateMoveLimit method", function() {


        it("It should test calculateMoveLimit method when stage.index === lastStage.index", function() {

            var moveElement = "step";

            var stage = {
                index: 1,
                previousStage: {
                    index: 0,
                    myWidth: 100,
                    left: 110
                }
            };

            eventSystem.calculateMoveLimit(moveElement, stage);

            expect(C.moveLimit).toEqual(stage.previousStage.myWidth + stage.previousStage.left);
        });

        it("It should test calculateMoveLimit method when holdTime.text === ∞", function() {

            var moveElement = "step";

            C.allStepViews = [
                {   
                    left: 180,
                    circle: {
                        holdTime: {
                            text: "∞"
                        }
                    }
                }
            ];

            var stage = {
                index: 10,
                previousStage: {
                    index: 3,
                    myWidth: 100,
                    left: 110
                }
            };

            eventSystem.calculateMoveLimit(moveElement, stage);

            expect(C.stepMoveLimit).toEqual(63);
        });
    });
});