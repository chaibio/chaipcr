describe("Testing stepEvents service", function() {

    var stepEvents, _stepGraphics, _TimeService, _pauseStepService, _moveRampLineService,
        $scope, canvas, C;

        beforeEach(function() {

            module("ChaiBioTech", function($provide) {
                $provide.value('IsTouchScreen', function () {});
            });

            inject(function($injector) {
                _stepGraphics = $injector.get('stepGraphics');
                _TimeService = $injector.get('TimeService');
                _pauseStepService = $injector.get('pauseStepService');
                _moveRampLineService = $injector.get('moveRampLineService');
                stepEvents = $injector.get('stepEvents');

                $scope = {
                    $watch: function(arg1, callback) {

                    }
                };

                canvas = {
                    renderAll: function() {}
                };

                C = {

                }; 

            });

        });

        it("It should test init method", function() {

            spyOn($scope, "$watch").and.returnValue(true);
            stepEvents.init($scope, canvas, C);
            expect($scope.$watch).toHaveBeenCalledTimes(9);
        });

        it("It should test manageTemperatureChange method", function() {

            _moveRampLineService.manageDrag = function() {

            };

            $scope.fabricStep = {
                circle: {
                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            spyOn(_moveRampLineService, "manageDrag");
            spyOn($scope.fabricStep.circle.circleGroup, "setCoords");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageTemperatureChange(10, 30);
            
            expect(_moveRampLineService.manageDrag).toHaveBeenCalled();
            expect($scope.fabricStep.circle.circleGroup.setCoords).toHaveBeenCalled();
            expect($scope.fabricStep.circle.circleGroup.top).toEqual(100);
            expect(canvas.renderAll).toHaveBeenCalled();
        });

        it("It should test manageRampRateChange", function() {
            
            $scope.fabricStep = {
                showHideRamp: function() {},
                circle: {
                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            spyOn($scope.fabricStep, "showHideRamp");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageRampRateChange();

            expect($scope.fabricStep.showHideRamp).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();
            
        });

        it("It should test manageStepNameChange method", function() {

            $scope.fabricStep = {
                index: 14,
                model: {
                    name: "chaibio",
                },
                stepName: {}
            };

            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepNameChange();

            expect(canvas.renderAll).toHaveBeenCalled();
            expect($scope.fabricStep.stepName.text).toEqual("Chaibio");
        });

        it("It should test manageStepNameChange method when model has no name", function() {

            $scope.fabricStep = {
                index: 14,
                model: {
                   // name: "chaibio",
                },
                stepName: {}
            };

            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepNameChange();

            expect(canvas.renderAll).toHaveBeenCalled();
            expect($scope.fabricStep.stepName.text).toEqual("Step " + ($scope.fabricStep.index + 1));
        });

        it("It should test manageStepHoldTimeChange method", function() {

            C.allStepViews = [
                {
                    index: 1,
                    name: "Step",
                    circle: {
                        doThingsForLast: function() {}
                    }
                }
            ];

            $scope.fabricStep = {
                index: 1,
                showHideRamp: function() {},
                circle: {
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            _TimeService.newTimeFormatting = function() {};

            spyOn(_TimeService, "newTimeFormatting");
            spyOn($scope.fabricStep.circle, "changeHoldTime");
            spyOn(C.allStepViews[0].circle, "doThingsForLast");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepHoldTimeChange();

            expect(_TimeService.newTimeFormatting).toHaveBeenCalled();
            expect($scope.fabricStep.circle.changeHoldTime).toHaveBeenCalled();
            expect(C.allStepViews[0].circle.doThingsForLast).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();
        });

        it("It should test manageStepCollectDataChange method", function() {

            $scope.fabricStep = {
                index: 1,
                showHideRamp: function() {},
                circle: {
                    parent: {
                        gatherDataDuringStep: {}
                    },
                    showHideGatherData: function() {},
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            spyOn($scope.fabricStep.circle, "showHideGatherData");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepCollectDataChange("I am new", "I am old");

            expect($scope.fabricStep.circle.showHideGatherData).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();
            expect($scope.fabricStep.circle.parent.gatherDataDuringStep).toEqual("I am new");
        });

        it("It should test manageStepRampCollectData method", function() {

            $scope.fabricStep = {
                index: 1,
                showHideRamp: function() {},
                parentStage: {
                    index: 1
                },
                circle: {
                    gatherDataDuringRampGroup: {
                        setVisible: function() {}
                    },
                    parent: {
                        gatherDataDuringStep: {},
                        gatherDataDuringRamp: {}
                    },
                    showHideGatherData: function() {},
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };
            
            spyOn($scope.fabricStep.circle.gatherDataDuringRampGroup, "setVisible");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepRampCollectData("I am new", "I am old");

            expect($scope.fabricStep.circle.gatherDataDuringRampGroup.setVisible).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();
            expect($scope.fabricStep.circle.parent.gatherDataDuringRamp).toEqual("I am new");
        });

        it("It should test manageStepRampCollectData method, when index === 0", function() {

            $scope.fabricStep = {
                index: 0,
                showHideRamp: function() {},
                parentStage: {
                    index: 0
                },
                circle: {
                    gatherDataDuringRampGroup: {
                        setVisible: function() {}
                    },
                    parent: {
                        gatherDataDuringStep: {},
                        gatherDataDuringRamp: {}
                    },
                    showHideGatherData: function() {},
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };
            
            spyOn($scope.fabricStep.circle.gatherDataDuringRampGroup, "setVisible");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepRampCollectData("I am new", "I am old");

            expect($scope.fabricStep.circle.gatherDataDuringRampGroup.setVisible).not.toHaveBeenCalled();
            expect(canvas.renderAll).not.toHaveBeenCalled();
        });
        
        it("It should test manageStepPause method", function() {

            $scope.fabricStep = {
                index: 0,
                showHideRamp: function() {},
                parentStage: {
                    index: 0
                },
                circle: {
                    gatherDataDuringRampGroup: {
                        setVisible: function() {}
                    },
                    parent: {
                        gatherDataDuringStep: {},
                        gatherDataDuringRamp: {}
                    },
                    showHideGatherData: function() {},
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            _pauseStepService.controlPause = function() {};

            spyOn(_pauseStepService, "controlPause");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepPause();

            expect(_pauseStepService.controlPause).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();

        });

        it("It should test manageStepDeltaDurationS method", function() {

            spyOn(stepEvents, "changeDeltaText");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepDeltaDurationS();

            expect(stepEvents.changeDeltaText).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();

        });

        it("It should test manageStepDeltaTemperature method", function() {

            spyOn(stepEvents, "changeDeltaText");
            spyOn(canvas, "renderAll");

            stepEvents.init($scope, canvas, C);
            stepEvents.manageStepDeltaTemperature();

            expect(stepEvents.changeDeltaText).toHaveBeenCalled();
            expect(canvas.renderAll).toHaveBeenCalled();

        });

        it("It should test changeDeltaText method", function() {

            $scope.fabricStep = {
                index: 0,
                showHideRamp: function() {},
                parentStage: {
                    index: 0,
                    model: {
                        stage_type: "cycling"
                    },
                    childSteps: [
                        {
                            index: 0
                        },
                        {
                            index: 1
                        }
                    ]
                },
                circle: {
                    gatherDataDuringRampGroup: {
                        setVisible: function() {}
                    },
                    parent: {
                        gatherDataDuringStep: {},
                        gatherDataDuringRamp: {}
                    },
                    showHideGatherData: function() {},
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            _stepGraphics.autoDeltaDetails = function() {};

            spyOn(_stepGraphics, "autoDeltaDetails");

            stepEvents.init($scope, canvas, C);
            stepEvents.changeDeltaText($scope);

            expect(_stepGraphics.autoDeltaDetails).toHaveBeenCalledTimes(2);
        });

        it("It should test changeDeltaText method when stage is not cycling", function() {

            $scope.fabricStep = {
                index: 0,
                showHideRamp: function() {},
                parentStage: {
                    index: 0,
                    model: {
                        stage_type: "holding"
                    },
                    childSteps: [
                        {
                            index: 0
                        },
                        {
                            index: 1
                        }
                    ]
                },
                circle: {
                    gatherDataDuringRampGroup: {
                        setVisible: function() {}
                    },
                    parent: {
                        gatherDataDuringStep: {},
                        gatherDataDuringRamp: {}
                    },
                    showHideGatherData: function() {},
                    changeHoldTime: function() {},

                    circleGroup: {
                        setCoords: function() {}
                    },
                    getTop: function() {
                        return {
                            top: 100,
                            left: 150
                        };
                    }
                }
            };

            _stepGraphics.autoDeltaDetails = function() {};

            spyOn(_stepGraphics, "autoDeltaDetails");

            stepEvents.init($scope, canvas, C);
            stepEvents.changeDeltaText($scope);

            expect(_stepGraphics.autoDeltaDetails).not.toHaveBeenCalledTimes(2);
        });

});