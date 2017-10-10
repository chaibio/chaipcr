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
            adjustRampSpeedPlacing: function() {},
            canvas: {
                add: function() {}
            },
            parentStage: {
                index: 201
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

    
});