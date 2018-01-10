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
                        index: 1,
                        left: 200
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
                    bringToFront: function() {},
                    renderAll: function() {}
                },
                addStages: function() {},
                setDefaultWidthHeight: function() {},
                
                $scope: {
                    $watch: function() {},
                    protocol: {
                        id: null
                    },
                    fabricStep: null
                },

                selectStep: function() {},
                initEvents: function() {},
                getComponents: function() {},
                addComponentsToStage: function() {},
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

        describe("Testing calculateMoveLimit method when holdTime.text === ∞ and when moveElement = step/stage", function() {
            
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

            it("it should test calculateMoveLimit method when holdTime.text === ∞ and moveElement === stage", function() {

                    var moveElement = "stage";

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

                    expect(C.moveLimit).toEqual(160);
                });
            });
        
    });

    it("It should test calculateMoveLimit when holdTime.text !== ∞", function() {

        var moveElement = "stage";

            C.allStepViews = [
                {   
                    left: 180,
                    circle: {
                        holdTime: {
                            text: "1"
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

            expect(C.moveLimit).toEqual(300);
            expect(C.stepMoveLimit).toEqual(180);

    });

    it("It should test footerMouseOver method", function() {

        var indicate = {
            changeText: function() {},
            currentStep: null,
            setLeft: function() {},
            setCoords: function() {},
            setVisible: function() {},
        };

        me = {
            parentStage: {
                index: 10
            },
            index: 10
        };

        var moveElement = "step";

        spyOn(indicate, "changeText");
        spyOn(indicate, "setLeft");
        spyOn(indicate, "setCoords");
        spyOn(indicate, "setVisible");

        spyOn(eventSystem, "calculateMoveLimit").and.returnValue(100);
        spyOn(C.canvas, "renderAll");
        spyOn(C.canvas, "bringToFront");

        eventSystem.footerMouseOver(indicate, me, moveElement);

        expect(indicate.changeText).toHaveBeenCalled();
        expect(indicate.setLeft).toHaveBeenCalled();
        expect(indicate.setCoords).toHaveBeenCalled();
        expect(indicate.setVisible).toHaveBeenCalled();
        expect(eventSystem.calculateMoveLimit).toHaveBeenCalled();
        expect(C.canvas.bringToFront).toHaveBeenCalled();
        expect(C.canvas.renderAll).toHaveBeenCalled();
        expect(C.moveLimit).toEqual(100);
    });

    it("It should test canvas.on (afterImagesLoaded) method", function() {

        _circleManager.addRampLinesAndCircles = function() {};

        spyOn(C, "addStages");
        spyOn(C, "setDefaultWidthHeight");
        spyOn(C, "selectStep");
        spyOn(C, "initEvents");
        spyOn(C, "getComponents");
        spyOn(C, "addComponentsToStage");
        spyOn(C.canvas, "renderAll");

        eventSystem.afterImagesLoaded();

        expect(C.addStages).toHaveBeenCalled();
        expect(C.setDefaultWidthHeight).toHaveBeenCalled();
        expect(C.selectStep).toHaveBeenCalled();
        expect(C.initEvents).toHaveBeenCalled();
        expect(C.getComponents).toHaveBeenCalled();
        expect(C.addComponentsToStage).toHaveBeenCalled();
        expect(C.canvas.renderAll).toHaveBeenCalled();
    });

    it("It should test scroll", function() {


        $('.canvas-containing').trigger('scroll');
        //expect(1).toEqual(2);
    });

});