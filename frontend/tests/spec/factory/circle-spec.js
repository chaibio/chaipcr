describe("Testing circle", function() {

    var _Constants, _circleGroup, _outerCircle, _centerCircle, _littleCircleGroup, _circleMaker, 
    _gatherDataGroupOnScroll, _gatherDataCircleOnScroll, _gatherDataGroup, _gatherDataCircle, _previouslySelected,
    _pauseStepOnScrollGroup, _pauseStepCircleOnScroll, _pauseStepService, _editModeService, _stepDataGroupService, _circle, circle;

    beforeEach(function() {
    
        module("ChaiBioTech", function ($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('gatherDataGroupOnScroll', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('gatherDataCircleOnScroll', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('pauseStepCircleOnScroll', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('pauseStepOnScrollGroup', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('gatherDataGroup', function() {
                return {
                    created: 'yes',
                    set: function() {},
                    setCoords: function() {}
                };
            });

            $provide.value('gatherDataCircle', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('circleGroup', function(data) {
                return data;
            });

            $provide.value('outerCircle', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('centerCircle', function() {

                return {
                    created: 'yes'
                };
            });

            $provide.value('littleCircleGroup', function(data) {

                return {
                    created: 'yes',
                    allData: data
                };
            });

            $provide.value('circleMaker', function() {
                return {
                    created: 'yes'
                };
            });

            $provide.value('previouslySelected',  {
                        circle: {
                            makeItSmall: function() {},
                            model: {
                                id: 134
                            }
                        }
                    }
                );
        });

        inject(function($injector) {

            _Constants = $injector.get('constants');
            _circleGroup = $injector.get('circleGroup');
            _outerCircle = $injector.get('outerCircle');
            _centerCircle = $injector.get('centerCircle');
            _littleCircleGroup = $injector.get('littleCircleGroup');
            _circleMaker = $injector.get('circleMaker');
            _gatherDataGroupOnScroll = $injector.get('gatherDataGroupOnScroll');
            _gatherDataCircleOnScroll = $injector.get('gatherDataCircleOnScroll');
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

        var model = {
            id: 101
        };

        var parentStep = {
            left: 100,
            selectStep: function() {},
            adjustRampSpeedPlacing: function() {},
            swapMoveStepStatus: function() {},
            canvas: {
                add: function() {},
                renderAll: function() {},
            },
            parentStage: {
                index: 201,
                selectStage: function() {},
                parent: {
                    editStageStatus: true,
                }
            }
        };

        var $scope = {};

        circle = new _circle(model, parentStep, $scope);
        
    });

    it("It should test getLeft method", function() {

        
        var retVal = circle.getLeft();
        expect(retVal.left).toEqual(100);
    });

    it("It sould test moveCircle method", function() {

        
        spyOn(circle, "getLeft").and.returnValue(100);
        spyOn(circle, "getTop").and.returnValue(40);

        circle.moveCircle();

        expect(circle.getLeft).toHaveBeenCalled();
        expect(circle.getTop).toHaveBeenCalled();
    });

    it("It should test setCenter method", function() {

        

        var imgObj = {

        };
        circle.setCenter(imgObj);

        expect(imgObj.originX).toEqual("center");
        expect(imgObj.originY).toEqual("center");
    });

    it("It should test getTop method, when tesmperature is set to zero", function() {

        circle.model = {
            temperature: 0
        };
        
        var retVal = circle.getTop();

        expect(retVal.top).toEqual(circle.scrollLength);
    });

    it("It should test getTop method, when tesmperature is set to 100", function() {

        circle.model = {
            temperature: 100
        };
        
        var retVal = circle.getTop();

        expect(retVal.top).toEqual(circle.scrollTop);
    });

    it("It should test moveCircleWithStep", function() {

        circle.left = 130;

        circle.circleGroup = {
            set: function() {},
            setCoords: function() {}
        };
        
        circle.stepDataGroup = {
            set: function() {},
            setCoords: function() {}
        };

        circle.gatherDataDuringRampGroup = {
            set: function() {},
            setCoords: function() {}
        };

        spyOn(circle.circleGroup, "set");
        spyOn(circle.stepDataGroup, "set");
        spyOn(circle.gatherDataDuringRampGroup, "set");

        spyOn(circle.circleGroup, "setCoords");
        spyOn(circle.stepDataGroup, "setCoords");
        spyOn(circle.gatherDataDuringRampGroup, "setCoords");

        circle.moveCircleWithStep();

        expect(circle.circleGroup.set).toHaveBeenCalled();
        expect(circle.stepDataGroup.set).toHaveBeenCalled();
        expect(circle.gatherDataDuringRampGroup.set).toHaveBeenCalled();

        expect(circle.circleGroup.setCoords).toHaveBeenCalled();
        expect(circle.stepDataGroup.setCoords).toHaveBeenCalled();
        expect(circle.gatherDataDuringRampGroup.setCoords).toHaveBeenCalled();
    });

    it("It should test addImages method", function() {

        circle.parent.parentStage = {
            parent: {
                imageobjects: [
                    
                ]
            }
        };

        circle.parent.parentStage.parent.imageobjects["gather-data.png"] = {};
        circle.parent.parentStage.parent.imageobjects["gather-data-image.png"] = {};
        circle.parent.parentStage.parent.imageobjects["gather-data.png"] = {
            setVisible: function() {}
        };
        circle.parent.parentStage.parent.imageobjects["pause.png"] = {};
        circle.parent.parentStage.parent.imageobjects["pause-middle.png"] = {
            setVisible: function() {}
        };

        spyOn(circle, "setCenter").and.returnValue(true);
        circle.addImages();
        expect(circle.setCenter).toHaveBeenCalledTimes(5);
    });

    it("It should test removeContents method", function() {

        circle.canvas = {
            remove: function() {}
        };

        spyOn(circle.canvas, "remove");
        circle.removeContents();
        expect(circle.canvas.remove).toHaveBeenCalledTimes(5);
    });

    it("It should test addStepDataGroup method", function() {

        circle.stepDataGroup = {
            set: function() {},
            setCoords: function() {}
        };

        circle.canvas = {
            add: function() {}
        };

        spyOn(circle.stepDataGroup, "set");
        spyOn(circle.stepDataGroup, "setCoords");
        spyOn(circle.canvas, "add");

        circle.addStepDataGroup();

        expect(circle.stepDataGroup.set).toHaveBeenCalled();
        expect(circle.stepDataGroup.setCoords).toHaveBeenCalled();
        expect(circle.canvas.add).toHaveBeenCalled();
    });

    it("It should test manageGatheDataScroll method", function() {

        circle.manageGatheDataScroll();

        expect(circle.gatherDataCircleOnScroll.created).toEqual('yes');
        expect(circle.gatherDataOnScroll.created).toEqual('yes');
    });

    it("It should test managePause method", function() {

        circle.managePause();
        expect(circle.pauseStepCircleOnScroll.created).toEqual('yes');
        expect(circle.pauseStepOnScrollGroup.created).toEqual('yes');

    });

    it("It should test manageGatherDataDuringRamp method", function() {

        circle.manageGatherDataDuringRamp();
        expect(circle.gatherDataDuringRampGroup.created).toEqual('yes');
    });

    it("It should test manageGatherDataDuringRamp method, when circle has previous", function() {

        circle.previous = {
            left: 100,
        };
        circle.manageGatherDataDuringRamp();
        expect(circle.gatherDataDuringRampGroup.created).toEqual('yes');
    });

    it("It should test addComponentsToCircleGroup method", function() {

        circle.circleGroup =  {
            add: function() {

            }
        };

        spyOn(circle.circleGroup, 'add');
        circle.addComponentsToCircleGroup();
        expect(circle.circleGroup.add).toHaveBeenCalledTimes(4);
    });


    it("It should test getCircle method", function() {

        circle.circleGroup = {
            set: function() {},
            setCoords: function() {},
            add: function() {},
        };

        spyOn(circle, "addStepDataGroup").and.returnValue(true);
        spyOn(circle, "manageGatheDataScroll").and.returnValue(true);
        spyOn(circle, "managePause").and.returnValue(true);
        spyOn(circle, "addComponentsToCircleGroup").and.returnValue(true);
        spyOn(circle, "manageGatherDataDuringRamp").and.returnValue(true);
        spyOn(circle, "showHideGatherData").and.returnValue();
        spyOn(circle, "runAlongCircle").and.returnValue(true);
        spyOn(_pauseStepService, "controlPause").and.returnValue(true);

        circle.getCircle();

        expect(circle.addStepDataGroup).toHaveBeenCalled();
        expect(circle.manageGatheDataScroll).toHaveBeenCalled();
        expect(circle.managePause).toHaveBeenCalled();

        expect(circle.addComponentsToCircleGroup).toHaveBeenCalled();
        expect(circle.manageGatherDataDuringRamp).toHaveBeenCalled();
        expect(circle.showHideGatherData).toHaveBeenCalled();
        expect(circle.runAlongCircle).toHaveBeenCalled();
        expect(_pauseStepService.controlPause).toHaveBeenCalled();

    });

    it("It should test getCircle method, when circle has previous", function() {

        circle.circleGroup = {
            set: function() {},
            setCoords: function() {},
            add: function() {},
        };

        circle.previous = {
            left: 110
        };

        circle.gatherDataDuringRampGroup = {
            setVisible: function() {},
        };

        spyOn(circle, "addStepDataGroup").and.returnValue(true);
        spyOn(circle, "manageGatheDataScroll").and.returnValue(true);
        spyOn(circle, "managePause").and.returnValue(true);
        spyOn(circle, "addComponentsToCircleGroup").and.returnValue(true);
        spyOn(circle, "manageGatherDataDuringRamp").and.returnValue(true);
        spyOn(circle, "showHideGatherData").and.returnValue();
        spyOn(circle, "runAlongCircle").and.returnValue(true);
        spyOn(_pauseStepService, "controlPause").and.returnValue(true);
        spyOn(circle.gatherDataDuringRampGroup, "setVisible").and.returnValue();

        circle.getCircle();

        expect(circle.addStepDataGroup).toHaveBeenCalled();
        expect(circle.manageGatheDataScroll).toHaveBeenCalled();
        expect(circle.managePause).toHaveBeenCalled();

        expect(circle.addComponentsToCircleGroup).toHaveBeenCalled();
        expect(circle.manageGatherDataDuringRamp).toHaveBeenCalled();
        expect(circle.showHideGatherData).toHaveBeenCalled();
        expect(circle.runAlongCircle).toHaveBeenCalled();
        expect(_pauseStepService.controlPause).toHaveBeenCalled();
        expect(circle.gatherDataDuringRampGroup.setVisible).toHaveBeenCalled();
    });

    it("It should test getUniqueId method", function() {

        var retVal = circle.getUniqueId();
        expect(retVal.uniqueName).toBeDefined();
        expect(retVal.uniqueName).toEqual('302circle');
    });

    it("It should test doThingsForLast method, when hold time is zero", function() {

        circle.model.hold_time = 0;
        circle.holdTime = {
            text: 'Chai'
        };

        var newHold = 0;
        var oldHold = 12;
        spyOn(circle.parent, "swapMoveStepStatus").and.returnValue(true);
        spyOn(_editModeService, "temporaryChangeForStatus").and.returnValue(true);
        spyOn(circle.canvas, "renderAll");

        circle.doThingsForLast(newHold, oldHold);

        expect(circle.parent.swapMoveStepStatus).toHaveBeenCalled();
        expect(circle.canvas.renderAll).toHaveBeenCalled();
        expect(_editModeService.temporaryChangeForStatus).toHaveBeenCalled();
        expect(circle.holdTime.text).toEqual('∞');

    });

    it("It should test doThingsForLast method, when hold time is not zero", function() {

        circle.model.hold_time = 12;
        circle.holdTime = {
            text: 'Chai'
        };

        var newHold = 12;
        var oldHold = 0;
        spyOn(circle.parent, "swapMoveStepStatus").and.returnValue(true);
        spyOn(_editModeService, "editModeStageChanges").and.returnValue(true);
        spyOn(circle.canvas, "renderAll");

        circle.doThingsForLast(newHold, oldHold);

        expect(circle.parent.swapMoveStepStatus).toHaveBeenCalled();
        expect(circle.canvas.renderAll).toHaveBeenCalled();
        expect(_editModeService.editModeStageChanges).toHaveBeenCalled();
    });

    it("It should test changeHoldTime method", function() {

        circle.holdTime = {
            text: 1
        };

        var newHold = 14;
        circle.changeHoldTime(newHold);
        expect(circle.holdTime.text).toEqual(newHold);
    });

    it("It should test render method", function() {

        spyOn(_stepDataGroupService, "newStepDataGroup").and.returnValue(true);

        circle.render();

        expect(_stepDataGroupService.newStepDataGroup).toHaveBeenCalled();
        expect(circle.circleGroup.length).toEqual(3);
        expect(circle.outerCircle.created).toEqual('yes');
        expect(circle.circle.created).toEqual('yes');
        expect(circle.littleCircleGroup.allData.length).toEqual(3);
    });

    it("It should test createNewStepDataGroup method", function() {

        spyOn(_stepDataGroupService, "reCreateNewStepDataGroup").and.returnValue(true);
        
        circle.createNewStepDataGroup();

        expect(_stepDataGroupService.reCreateNewStepDataGroup).toHaveBeenCalled();
    });

    it("It should test makeItBig method, when collect_data is on", function() {

        circle.big = false;

        circle.circle = {

            setFill: function(color) {},
            setStroke: function() {},

        };

        circle.gatherDataImageMiddle = {
            setVisible: function() {},
        };

        circle.gatherDataOnScroll = {
            setVisible: function() {}
        };

        circle.outerCircle = {
            setStroke: function() {},
            strokeWidth: 0
        };
        
        circle.littleCircleGroup = {
            visible: false
        };

        circle.model = {
            collect_data: true,
            pause: false
        };

        spyOn(circle.circle, "setFill");
        spyOn(circle.gatherDataImageMiddle, "setVisible");
        spyOn(circle.gatherDataOnScroll, "setVisible");
        spyOn(circle.circle, "setStroke");
        spyOn(circle.outerCircle, "setStroke");

        circle.makeItBig();

        expect(circle.circle.setFill).toHaveBeenCalled();
        expect(circle.gatherDataImageMiddle.setVisible).toHaveBeenCalled();
        expect(circle.gatherDataOnScroll.setVisible).toHaveBeenCalled();
        expect(circle.circle.setStroke).toHaveBeenCalled();
        expect(circle.outerCircle.setStroke).toHaveBeenCalled();
        expect(circle.outerCircle.strokeWidth).toEqual(5);
        expect(circle.littleCircleGroup.visible).toEqual(true);
        expect(circle.big).toEqual(true);
    });

    it("It should test makeItBig method, when collect_data is onand pause is set on", function() {

        circle.big = false;

        circle.circle = {

            setFill: function(color) {},
            setStroke: function() {},

        };

        circle.gatherDataImageMiddle = {
            setVisible: function() {},
        };

        circle.gatherDataOnScroll = {
            setVisible: function() {}
        };

        circle.outerCircle = {
            setStroke: function() {},
            strokeWidth: 0
        };
        
        circle.littleCircleGroup = {
            visible: false
        };

        circle.pauseImageMiddle = {
            setVisible: function() {}
        };

        circle.pauseStepOnScrollGroup = {
            setVisible: function() {}
        };

        circle.model = {
            collect_data: true,
            pause: true,
        };

        spyOn(circle.circle, "setFill");
        spyOn(circle.gatherDataImageMiddle, "setVisible");
        spyOn(circle.gatherDataOnScroll, "setVisible");
        spyOn(circle.circle, "setStroke");
        spyOn(circle.outerCircle, "setStroke");
        spyOn(circle.pauseImageMiddle, "setVisible");
        spyOn(circle.pauseStepOnScrollGroup, "setVisible");

        circle.makeItBig();

        expect(circle.circle.setFill).toHaveBeenCalled();
        expect(circle.gatherDataImageMiddle.setVisible).toHaveBeenCalled();
        expect(circle.gatherDataOnScroll.setVisible).toHaveBeenCalled();
        expect(circle.circle.setStroke).toHaveBeenCalled();
        expect(circle.outerCircle.setStroke).toHaveBeenCalled();
        expect(circle.pauseImageMiddle.setVisible).toHaveBeenCalled();
        expect(circle.pauseStepOnScrollGroup.setVisible).toHaveBeenCalled();
        expect(circle.outerCircle.strokeWidth).toEqual(5);
        expect(circle.littleCircleGroup.visible).toEqual(true);
        expect(circle.big).toEqual(true);
    });

    it("It should test makeItSmall method", function() {

         circle.circle = {
            setFill: function(color) {},
            setStroke: function() {},
            setRadius: function() {},
            setStrokeWidth: function() {},
        };
        
        circle.outerCircle = {
            setStroke: function() {}
        };

        circle.stepDataGroup = {
            setVisible: function() {},
        };

        circle.littleCircleGroup = {
            visible:  true
        };

        circle.model = {
            collect_data: false,
            pause: true,
        };

        circle.gatherDataImageMiddle = {
            setVisible: function() {}
        };

        circle.gatherDataOnScroll = {
            setVisible: function() {}
        };

        spyOn(_pauseStepService, "applyPauseChanges").and.returnValue(true);
        spyOn(circle.circle, "setFill");
        spyOn(circle.circle, "setStroke");
        spyOn(circle.circle, "setRadius");
        spyOn(circle.circle, "setStrokeWidth");
        spyOn(circle.outerCircle, "setStroke");
        spyOn(circle.stepDataGroup, "setVisible");
        spyOn(circle.gatherDataImageMiddle, "setVisible");
        spyOn(circle.gatherDataOnScroll, "setVisible");

        circle.makeItSmall();

        expect(circle.big).toEqual(false);
        expect(circle.circle.setFill).toHaveBeenCalledWith("#ffb400");
        expect(circle.circle.setStroke).toHaveBeenCalledWith("white");
        expect(circle.circle.setRadius).toHaveBeenCalledWith(11);
        expect(circle.circle.setStrokeWidth).toHaveBeenCalledWith(8);

        expect(circle.outerCircle.setStroke).toHaveBeenCalledWith(null);
        expect(circle.stepDataGroup.setVisible).toHaveBeenCalledWith(true);
        expect(circle.littleCircleGroup.visible).toEqual(false);
        expect(_pauseStepService.applyPauseChanges).toHaveBeenCalled();

    });

    it("It should test makeItSmall method, when collect_data turned on", function() {

         circle.circle = {
            setFill: function(color) {},
            setStroke: function() {},
            setRadius: function() {},
            setStrokeWidth: function() {},
        };
        
        circle.outerCircle = {
            setStroke: function() {}
        };

        circle.stepDataGroup = {
            setVisible: function() {},
        };

        circle.littleCircleGroup = {
            visible:  true
        };

        circle.model = {
            collect_data: true,
            pause: true,
        };

        circle.gatherDataImageMiddle = {
            setVisible: function() {}
        };

        circle.gatherDataOnScroll = {
            setVisible: function() {}
        };

        spyOn(_pauseStepService, "applyPauseChanges").and.returnValue(true);
        spyOn(circle.circle, "setFill");
        spyOn(circle.circle, "setStroke");
        spyOn(circle.circle, "setRadius");
        spyOn(circle.circle, "setStrokeWidth");
        spyOn(circle.outerCircle, "setStroke");
        spyOn(circle.stepDataGroup, "setVisible");
        spyOn(circle.gatherDataImageMiddle, "setVisible");
        spyOn(circle.gatherDataOnScroll, "setVisible");

        circle.makeItSmall();

        expect(circle.big).toEqual(false);
        expect(circle.circle.setFill).toHaveBeenCalledWith("white");
        expect(circle.circle.setStroke).toHaveBeenCalledWith("white");
        expect(circle.circle.setRadius).toHaveBeenCalledWith(11);
        expect(circle.circle.setStrokeWidth).toHaveBeenCalledWith(8);

        expect(circle.outerCircle.setStroke).toHaveBeenCalledWith(null);
        expect(circle.stepDataGroup.setVisible).toHaveBeenCalledWith(true);
        expect(circle.littleCircleGroup.visible).toEqual(false);
        expect(_pauseStepService.applyPauseChanges).toHaveBeenCalled();

        expect(circle.gatherDataImageMiddle.setVisible).toHaveBeenCalledWith(true);
        expect(circle.gatherDataOnScroll.setVisible).toHaveBeenCalledWith(false);
    });

    it("It should test showHideGatherData method, when staus is true and circle is small", function() {

        var status = true;
        circle.big = false;
        circle.circle = {
            setFill: function() {}
        };

        circle.gatherDataImageMiddle = {
            setVisible: function() {}
        };

        spyOn(circle.circle, "setFill");
        spyOn(circle.gatherDataImageMiddle, "setVisible");

        circle.showHideGatherData(status);

        expect(circle.circle.setFill).toHaveBeenCalledWith("white");
        expect(circle.gatherDataImageMiddle.setVisible).toHaveBeenCalledWith(status);
    });

    it("It should test showHideGatherData method, when staus is false", function() {

        var status = false;
        circle.big = true;
        circle.circle = {
            setFill: function() {}
        };

        circle.gatherDataImageMiddle = {
            setVisible: function() {}
        };

        circle.gatherDataOnScroll = {
            setVisible: function() {}
        };

        spyOn(circle.circle, "setFill");
        spyOn(circle.gatherDataOnScroll, "setVisible");

        circle.showHideGatherData(status);

        expect(circle.circle.setFill).toHaveBeenCalledWith("#ffb400");
        expect(circle.gatherDataOnScroll.setVisible).toHaveBeenCalled();
    });

    it("It should test temperatureDisplay method, temperature less than 50", function() {

        circle.temperature = {
            text: "10"
        };
        var targetCircleGroup = {
            top: 300
        };
        
        circle.temperatureDisplay(targetCircleGroup);
        
        expect(circle.model.temperature).toEqual('14.3');
        expect(circle.temperature.text).toEqual('14.3º');
    });

    it("It should test temperatureDisplay method, temperature greater than 50", function() {

        circle.temperature = {
            text: "10"
        };
        var targetCircleGroup = {
            top: 100
        };
        
        circle.temperatureDisplay(targetCircleGroup);
        
        expect(circle.model.temperature).toEqual('94.4');
        expect(circle.temperature.text).toEqual('94.4º');
    });

    it("It should test temperatureDisplay method, temperature greater than 100", function() {

        circle.temperature = {
            text: "10"
        };
        var targetCircleGroup = {
            top: 10
        };
        
        circle.temperatureDisplay(targetCircleGroup);
        
        expect(circle.model.temperature).toEqual('100');
        expect(circle.temperature.text).toEqual('100º');
    });

    it("It should test manageClick method", function() {

        circle.big = false;
        spyOn(circle.canvas, "renderAll");
        spyOn(circle, "makeItBig").and.returnValue(true);
        spyOn(circle.parent, "selectStep");
        spyOn(circle.parent.parentStage, "selectStage");


        circle.manageClick();

        expect(circle.canvas.renderAll).toHaveBeenCalled();
        expect(circle.makeItBig).toHaveBeenCalled();
        expect(circle.parent.selectStep);
        expect(circle.parent.parentStage.selectStage).toHaveBeenCalled();
    });

    it("It should test manageClick method, when the circle has a previous circle", function() {

        circle.big = false;
        circle.model.id = 100;

        spyOn(circle.canvas, "renderAll");
        spyOn(circle, "makeItBig").and.returnValue(true);
        spyOn(circle.parent, "selectStep");
        spyOn(circle.parent.parentStage, "selectStage");
        spyOn(_previouslySelected.circle, "makeItSmall");

        circle.manageClick();

        expect(circle.canvas.renderAll).toHaveBeenCalled();
        expect(circle.makeItBig).toHaveBeenCalled();
        expect(circle.parent.selectStep);
        expect(circle.parent.parentStage.selectStage).toHaveBeenCalled();
        expect(_previouslySelected.circle.model.id).toEqual(100);
    });

    it("It should test runAlongEdge method", function() {

        circle.next = {
            parent: {
                left: 20,
                rampSpeedGroup: {
                    height: 47,
                    setCoords: function() {},
                    top: 20,
                    left: 30
                },

            },
            gatherDataDuringRampGroup: {
                setCoords: function() {},
                top: 100
            },

        };

        spyOn(circle.next.gatherDataDuringRampGroup, "setCoords");
        spyOn(circle.next.parent.rampSpeedGroup, "setCoords");

        circle.runAlongEdge();

        expect(circle.next.gatherDataDuringRampGroup.setCoords).toHaveBeenCalled();
        expect(circle.next.parent.rampSpeedGroup.setCoords).toHaveBeenCalled();
        expect(circle.next.parent.rampSpeedGroup.left).toEqual(25);
    });

    it("It should test runAlongEdge method, when ((rampEdge > this.next.gatherDataDuringRampGroup.top - 14) && this.next.parent.rampSpeedGroup.top < this.next.gatherDataDuringRampGroup.top + 16)", function() {

        circle.next = {
            parent: {
                left: 20,
                rampSpeedGroup: {
                    height: 110,
                    setCoords: function() {},
                    top: 20,
                    left: 30
                },

            },
            gatherDataDuringRampGroup: {
                setCoords: function() {},
                top: 100
            },

        };

        spyOn(circle.next.gatherDataDuringRampGroup, "setCoords");
        spyOn(circle.next.parent.rampSpeedGroup, "setCoords");

        circle.runAlongEdge();

        expect(circle.next.gatherDataDuringRampGroup.setCoords).toHaveBeenCalled();
        expect(circle.next.parent.rampSpeedGroup.setCoords).toHaveBeenCalled();
        expect(circle.next.parent.rampSpeedGroup.left).toEqual(36);
    });

    it("It should test runAlongCircle method, when (rampEdge < this.gatherDataDuringRampGroup.top - 14)", function() {

        circle.gatherDataDuringRampGroup = {
            top: 100,
            setCoords: function() { },
        };

        circle.parent = {
            left:50,
            rampSpeedGroup: {
                top: 70,
                height: 15,
                left: 0,
                setCoords: function() {},
            }
        };

        circle.runAlongCircle();

        expect(circle.parent.rampSpeedGroup.left).toEqual(circle.parent.left + 5);
    });

    it("It should test runAlongCircle method, when ((rampEdge > this.gatherDataDuringRampGroup.top - 14) && this.parent.rampSpeedGroup.top < this.gatherDataDuringRampGroup.top + 16)", function() {

        circle.gatherDataDuringRampGroup = {
            top: 60,
            setCoords: function() { },
        };

        circle.parent = {
            left:50,
            rampSpeedGroup: {
                top: 70,
                height: 15,
                left: 0,
                setCoords: function() {},
            }
        };
        circle.runAlongCircle();

        expect(circle.parent.rampSpeedGroup.left).toEqual(62.48999599679679);
        
    });

    it("It should test runAlongCircle method, when ((rampEdge > this.gatherDataDuringRampGroup.top - 14) && this.parent.rampSpeedGroup.top < this.gatherDataDuringRampGroup.top + 16)", function() {

        circle.gatherDataDuringRampGroup = {
            top: 90,
            setCoords: function() { },
        };

        circle.parent = {
            left:50,
            rampSpeedGroup: {
                top: 70,
                height: 15,
                left: 0,
                setCoords: function() {},
            }
        };
        circle.runAlongCircle();

        expect(circle.parent.rampSpeedGroup.left).toEqual(65.19868415357067);
        
    });


});
