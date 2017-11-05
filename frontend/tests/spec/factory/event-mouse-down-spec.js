describe("Testing mouse-down events", function() {

    var mouseDown, _ExperimentLoader, _circleManager, _editMode, _movingStepGraphics, _correctNumberingService, C,
    that;
    beforeEach(function() {

    module('ChaiBioTech', function($provide) {
        $provide.value('IsTouchScreen', function () {});
        $provide.value('editMode', {
            tempActive: true,
            holdActive: false,
            currentActiveTemp: {
                fire: function() {}
            }
        });
    });

    inject(function($injector) {
        _ExperimentLoader = $injector.get('ExperimentLoader');
        _correctNumberingService = $injector.get('correctNumberingService');
        _movingStepGraphics = $injector.get('movingStepGraphics');
        _editMode = $injector.get('editMode');
        _circleManager = $injector.get('circleManager');
        _correctNumberingService = $injector.get('correctNumberingService');
        mouseDown = $injector.get('mouseDown');

        C = {
            stepIndicator: {
                init: function() {},
                initForOneStepStage: function() {}
            },
            moveDots: {
                baseStep: {},
                setLeft: function() {},
                setCoords: function() {},
                setVisible: function() {},
            },
            stageIndicator: {
                init: function() {},
                changeText: function() {}
            },
            canvas: {
                remove: function() {},
                add: function() {},
                renderAll: function() {},
                setActiveObject: function() {},
                bringToFront: function() {},
            }
        };
        var $scope = {}; 
        that = {
            setSummaryMode: function() {},
            selectStep: function() {},
            calculateMoveLimit: function() {},
            canvas: {
                moveCursor: "X",
                getPointer: function() {},
            }
        };

        // This is a little patch;
        mouseDown.canvas = {
            on: function() {}
        };
        mouseDown.init(C, $scope, that);

    });

   });


   it("It should test if init method call is alright", function() {
        expect(mouseDown.mouseDownHandler).toEqual(jasmine.any(Function));
   });

   it("It should test unHookGroup method", function() {

        var group = {
            _restoreObjectsState: function() {}
        };

        var items = [
            { index: 1 },
            { index: 2 },
            { index: 3 },
            { index: 4 }
        ];

        var index_to_remove = 1;

        spyOn(group, "_restoreObjectsState");
        spyOn(C.canvas, "remove");
        spyOn(C.canvas, "add");
        spyOn(C.canvas, "renderAll");

        mouseDown.unHookGroup(group, items, index_to_remove);

        expect(group._restoreObjectsState).toHaveBeenCalled();
        expect(C.canvas.remove).toHaveBeenCalled();
        expect(C.canvas.add).toHaveBeenCalledTimes(3);
        expect(C.canvas.renderAll).toHaveBeenCalled();
        expect(items.length).toEqual(3);
   });


   it("It should test startEditing method", function() {

        var textToBeEdited = {
            getSelectionStartFromPointer: function() {},
            moveCursorRightWithoutShift: function() {},
            enterEditing: function() {},
        };

        var evt = {};


        spyOn(textToBeEdited, "getSelectionStartFromPointer").and.returnValue(2);
        spyOn(textToBeEdited, "moveCursorRightWithoutShift");
        spyOn(textToBeEdited, "enterEditing");
        spyOn(C.canvas, "setActiveObject");

        mouseDown.startEditing(textToBeEdited, evt);

        expect(textToBeEdited.getSelectionStartFromPointer).toHaveBeenCalled();
        expect(textToBeEdited.moveCursorRightWithoutShift).toHaveBeenCalledTimes(2);
        expect(C.canvas.setActiveObject).toHaveBeenCalled();
   });

   describe("TEsting different scenarios in mouseDownHandler", function() {

        it("It should test mouseDownHandler method, when evt has no target", function() {

            var evt = {
                target: null
            };

            spyOn(that, "setSummaryMode");

            var retVal = mouseDown.mouseDownHandler(evt);

            expect(that.setSummaryMode).toHaveBeenCalled();
            expect(retVal).toEqual(false);
        });

        it("It should test mouseDownHandler when clicked on stepDataGroup", function() {

            var evt = {
                target: {
                    name: "stepDataGroup"
                }
            };

            spyOn(mouseDown, "stepDataGroupHandler").and.returnValue(true);

            mouseDown.mouseDownHandler(evt);

            expect(mouseDown.stepDataGroupHandler).toHaveBeenCalled();
        });

        it("It should test mouseDownHandler when clicked on stepGroup", function() {

            var evt = {
                target: {
                    name: "stepGroup",
                    me: {
                        name: "me"
                    }
                }
            };

            spyOn(that, "selectStep");

            mouseDown.mouseDownHandler(evt);

            expect(that.selectStep).toHaveBeenCalled();
        });

        it("It should test mouseDownHandler when clicked on controlCircleGroup", function() {

            var evt = {
                target: {
                    name: "controlCircleGroup",
                    me: {
                        name: "me"
                    }
                }
            };
            spyOn(that, "selectStep");
            mouseDown.mouseDownHandler(evt);
            expect(that.selectStep).toHaveBeenCalled();
            expect(that.canvas.moveCursor).toEqual('ns-resize');
        });

        it("It should test mouseDownHandler when clicked on moveStep", function() {

            var evt = {
                target: {
                    name: "moveStep",
                    me: {
                        name: "me"
                    }
                }
            };

            spyOn(mouseDown, "moveStepHandler");

            mouseDown.mouseDownHandler(evt);

            expect(mouseDown.moveStepHandler).toHaveBeenCalled();
        });

        it("It should test mouseDownHandler when clicked on moveStage", function() {

            var evt = {
                target: {
                    name: "moveStage",
                    me: {
                        name: "me"
                    }
                }
            };

            spyOn(mouseDown, "moveStageHandler");
            mouseDown.mouseDownHandler(evt);
            expect(mouseDown.moveStageHandler);
        });

        it("It should test mouseDownHandler when clicked on deleteStepButton", function() {

            var evt = {
                target: {
                    name: "deleteStepButton",
                    me: {
                        name: "me"
                    }
                }
            };

            spyOn(mouseDown, "deleteStepHandler");

            mouseDown.mouseDownHandler(evt);

            expect(mouseDown.deleteStepHandler).toHaveBeenCalled();
        });
        
   });

   it("It should test deleteStepHandler method", function() {

        var evt = {
            target: {
                me: {
                    parentStage: {
                        deleteStep: function() {}
                    },
                    circle: {

                    }
                }
            }
        };

        spyOn(that, "selectStep");

        spyOn(_ExperimentLoader, "deleteStep").and.returnValue({
            then: function(func) {
                var data;
                func(data);
            }
        });

        spyOn(evt.target.me.parentStage, "deleteStep");
        spyOn(C.canvas, "renderAll");

        mouseDown.deleteStepHandler(evt);
        
        expect(that.selectStep).toHaveBeenCalled();
        expect(_ExperimentLoader.deleteStep).toHaveBeenCalled();
        expect(evt.target.me.parentStage.deleteStep).toHaveBeenCalled();
        expect(C.canvas.renderAll).toHaveBeenCalled();
   });

   it("It should test moveStageHandler method", function() {

        var evt = {
            e: {
                clientX: 100
            },
            target: {
                parent: {
                    collapseStage: function() {},
                    wireStageNextAndPrevious: function() {},
                    removeFromStagesArray: function() {},
                }
            }
        };

        spyOn(_circleManager, "togglePaths").and.returnValue(true);
        spyOn(_correctNumberingService, "correctNumbering").and.returnValue(true);
        var stage = evt.target.parent;

        spyOn(stage, "collapseStage");
        spyOn(stage, "wireStageNextAndPrevious");
        spyOn(stage, "removeFromStagesArray");
        spyOn(that, "calculateMoveLimit");
        
        mouseDown.moveStageHandler(evt);
        
        expect(_circleManager.togglePaths).toHaveBeenCalled();
        expect(_correctNumberingService.correctNumbering).toHaveBeenCalled();
        expect(that.mouseDownPos).toEqual(evt.e.clientX);
        expect(that.canvas.moveCursor).toEqual("move");
        expect(stage.collapseStage).toHaveBeenCalled();
        expect(stage.wireStageNextAndPrevious).toHaveBeenCalled();
        expect(stage.removeFromStagesArray).toHaveBeenCalled();
        expect(that.calculateMoveLimit).toHaveBeenCalled();

   });

   describe("Testing stepDataGroupHandler method in deiffernet conditions", function() {
        
        it("It should test stepDataGroupHandler method", function() {

                var evt = {
                    target: {
                        left: 130,
                        parentCircle: {
                            holdTime: 10,
                            model: {
                                pause: false
                            },
                            stepDataGroup: {
                                _objects: {

                                }
                            }
                        }
                    },
                    e: {

                    }
                };

                spyOn(that.canvas, "getPointer").and.returnValue({
                    x: 10,
                    y: 70
                });

                spyOn(that, "selectStep").and.returnValue(true);
                spyOn(mouseDown, "unHookGroup").and.returnValue(true);
                spyOn(mouseDown, "startEditing").and.returnValue(true);

                mouseDown.stepDataGroupHandler(evt);

                expect(that.canvas.getPointer).toHaveBeenCalled();
                expect(that.selectStep).toHaveBeenCalled();
                expect(mouseDown.unHookGroup).toHaveBeenCalled();
                expect(mouseDown.startEditing).toHaveBeenCalled();
        });

        it("It should test stepDataGroupHandler method when first if statement is true", function() {

                var evt = {
                        target: {
                            left: 200,
                            parentCircle: {
                                holdTime: 10,
                                temperature: 45,
                                model: {
                                    pause: false
                                },
                                stepDataGroup: {
                                    _objects: {

                                    }
                                }
                            }
                        },
                        e: {

                        }
                    };

                spyOn(that.canvas, "getPointer").and.returnValue({
                    x: 150,
                    y: 70
                });

                spyOn(that, "selectStep").and.returnValue(true);
                spyOn(mouseDown, "unHookGroup").and.returnValue(true);
                spyOn(mouseDown, "startEditing").and.returnValue(true);

                mouseDown.stepDataGroupHandler(evt);

                expect(that.canvas.getPointer).toHaveBeenCalled();
                expect(that.selectStep).toHaveBeenCalled();
                expect(mouseDown.unHookGroup).toHaveBeenCalled();
                expect(mouseDown.startEditing).toHaveBeenCalled();
                expect(_editMode.tempActive).toEqual(true);
                expect(_editMode.currentActiveTemp).toEqual(evt.target.parentCircle.temperature);
        });
   });

   describe("Testing different scenarios in moveStepHandler method", function() {
        
        it("It should test moveStepHandler method when hold_time = 0", function() {

            var evt = {
                target: {
                    parent: {
                        model: {
                            hold_time: 0
                        }
                    },

                    left: 200,
                    parentStage: {
                        model:  {

                        }
                    },
                    parentCircle: {
                        holdTime: 10,
                        temperature: 45,
                        model: {
                            pause: false
                        },
                        stepDataGroup: {
                            _objects: {

                            }
                        }
                    }
                },
                e: {

                }
            };

            spyOn(that, "selectStep").and.returnValue(true);

            mouseDown.moveStepHandler(evt);

            expect(that.selectStep).not.toHaveBeenCalled();
        });

        it("It should test moveStepHandler method when hold_time != 0", function() {

            var evt = {
                target: {
                    setVisible: function() {},
                    setCoords: function() {},
                    setLeft: function() {},
                    parent: {
                        parentStage: {
                            squeezeStage: function() {}
                        },
                        previousStep: {},
                        circle: {

                        },
                        model: {
                            hold_time: 50
                        }
                    },

                    left: 200,
                    parentStage: {

                    },
                    parentCircle: {
                        holdTime: 10,
                        temperature: 45,
                        model: {
                            pause: false
                        },
                        stepDataGroup: {
                            _objects: {

                            }
                        }
                    }
                },
                e: {

                }
            };

            spyOn(_movingStepGraphics, "initiateMoveStepGraphics").and.returnValue(true);
            spyOn(that, "selectStep").and.returnValue(true);
            spyOn(that, "calculateMoveLimit").and.returnValue(true);
            spyOn(evt.target, "setVisible");
            spyOn(C.moveDots, "setVisible");
            spyOn(C.moveDots, "setCoords");
            spyOn(C.moveDots, "setLeft");
            spyOn(evt.target.parent.parentStage, "squeezeStage");

            spyOn(_circleManager, "togglePaths").and.returnValue(true);

            mouseDown.moveStepHandler(evt);

            expect(_movingStepGraphics.initiateMoveStepGraphics).toHaveBeenCalled();
            expect(that.selectStep).toHaveBeenCalled();
            expect(that.calculateMoveLimit).toHaveBeenCalled();
            expect(evt.target.setVisible).toHaveBeenCalled();
            
            expect(C.moveDots.setCoords).toHaveBeenCalled();
            expect(C.moveDots.setLeft).toHaveBeenCalled();
            expect(evt.target.parent.parentStage.squeezeStage).toHaveBeenCalled();
        });

        it("It should test moveStepHandler method when nextStep and previousStep are null", function() {

            var evt = {
                target: {
                    setVisible: function() {},
                    setCoords: function() {},
                    setLeft: function() {},
                    parent: {
                        nextStep: null,
                        previousStep: null,
                        parentStage: {
                            squeezeStage: function() {},
                            deleteStep: function() {},
                        },
                        
                        circle: {

                        },
                        model: {
                            hold_time: 50
                        }
                    },

                    left: 200,
                    parentStage: {

                    },
                    parentCircle: {
                        holdTime: 10,
                        temperature: 45,
                        model: {
                            pause: false
                        },
                        stepDataGroup: {
                            _objects: {

                            }
                        }
                    }
                },
                e: {

                }
            };

            spyOn(_movingStepGraphics, "initiateMoveStepGraphics").and.returnValue(true);
            spyOn(that, "selectStep").and.returnValue(true);
            spyOn(that, "calculateMoveLimit").and.returnValue(true);
            spyOn(evt.target, "setVisible");
            spyOn(C.moveDots, "setVisible");
            spyOn(C.moveDots, "setCoords");
            spyOn(C.moveDots, "setLeft");
            spyOn(evt.target.parent.parentStage, "squeezeStage");

            spyOn(evt.target.parent.parentStage, "deleteStep");
            spyOn(_circleManager, "togglePaths").and.returnValue(true);

            mouseDown.moveStepHandler(evt);

            expect(_movingStepGraphics.initiateMoveStepGraphics).toHaveBeenCalled();
            expect(that.selectStep).toHaveBeenCalled();
            expect(that.calculateMoveLimit).toHaveBeenCalled();
            expect(evt.target.setVisible).toHaveBeenCalled();
            
            expect(C.moveDots.setCoords).not.toHaveBeenCalled();
            expect(C.moveDots.setLeft).not.toHaveBeenCalled();
            expect(evt.target.parent.parentStage.squeezeStage).not.toHaveBeenCalled();
            expect(evt.target.parent.parentStage.deleteStep).toHaveBeenCalled();

        });

        it("It should test moveStepHandler method when stage has nextStage", function() {

            var evt = {
                target: {
                    setVisible: function() {},
                    setCoords: function() {},
                    setLeft: function() {},
                    parent: {
                        parentStage: {
                            squeezeStage: function() {},
                            nextStage: {
                                moveAllStepsAndStages: function() {}
                            }
                        },
                        previousStep: {},
                        circle: {

                        },
                        model: {
                            hold_time: 50
                        }
                    },

                    left: 200,
                    parentStage: {

                    },
                    parentCircle: {
                        holdTime: 10,
                        temperature: 45,
                        model: {
                            pause: false
                        },
                        stepDataGroup: {
                            _objects: {

                            }
                        }
                    }
                },
                e: {

                }
            };

            spyOn(_movingStepGraphics, "initiateMoveStepGraphics").and.returnValue(true);
            spyOn(that, "selectStep").and.returnValue(true);
            spyOn(that, "calculateMoveLimit").and.returnValue(true);
            spyOn(evt.target, "setVisible");
            spyOn(C.moveDots, "setVisible");
            spyOn(C.moveDots, "setCoords");
            spyOn(C.moveDots, "setLeft");
            spyOn(evt.target.parent.parentStage, "squeezeStage");

            spyOn(_circleManager, "togglePaths").and.returnValue(true);

            spyOn(evt.target.parent.parentStage.nextStage, "moveAllStepsAndStages");

            mouseDown.moveStepHandler(evt);

            expect(_movingStepGraphics.initiateMoveStepGraphics).toHaveBeenCalled();
            expect(that.selectStep).toHaveBeenCalled();
            expect(that.calculateMoveLimit).toHaveBeenCalled();
            expect(evt.target.setVisible).toHaveBeenCalled();
            
            expect(C.moveDots.setCoords).toHaveBeenCalled();
            expect(C.moveDots.setLeft).toHaveBeenCalled();
            expect(evt.target.parent.parentStage.squeezeStage).toHaveBeenCalled();
            expect(evt.target.parent.parentStage.nextStage.moveAllStepsAndStages).toHaveBeenCalled();
        });
   });
   
});