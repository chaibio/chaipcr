describe("Testing moveRampLineService", function() {

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {


        });

        inject(function($injector) {
            _moveRampLineService = $injector.get('moveRampLineService');
        });

    });

    it("It should test manageDrag method when top < scrollTop", function() {

        var targetCircleGroup = {
            setTop: function() {},
            top: 100,
            left: 150,
            me: {
                scrollTop: 180
            }
        };     

        spyOn(targetCircleGroup, "setTop");
        spyOn(_moveRampLineService, "manageRampLineMovement").and.returnValue(true);

        _moveRampLineService.manageDrag(targetCircleGroup);

        expect(targetCircleGroup.setTop).toHaveBeenCalledWith(targetCircleGroup.me.scrollTop);  
        expect(_moveRampLineService.manageRampLineMovement).toHaveBeenCalled(); 
    });

    it("It should test manageDrag method when top > parentCircle.lowestScrollCoordinate", function() {

        var targetCircleGroup = {
            setTop: function() {},
            top: 351,
            left: 150,
            me: {
                scrollTop: 180,
                lowestScrollCoordinate: 350,
            }
        };   

        spyOn(targetCircleGroup, "setTop");
        spyOn(_moveRampLineService, "manageRampLineMovement").and.returnValue(true);

        _moveRampLineService.manageDrag(targetCircleGroup);

        expect(targetCircleGroup.setTop).toHaveBeenCalledWith(targetCircleGroup.me.lowestScrollCoordinate);  
        expect(_moveRampLineService.manageRampLineMovement).toHaveBeenCalled();
    });

    it("It should test manageDrag method when else statement is executed", function() {

        var targetCircleGroup = {
            setTop: function() {},
            top: 12,
            left: 150,
            me: {
                scrollTop: 12,
                lowestScrollCoordinate: 12,
                stepDataGroup: {
                    setTop: function() {
                        
                    }
                }
            }
        };   

        spyOn(targetCircleGroup.me.stepDataGroup, "setTop").and.returnValue({
            setCoords: function() {}
        });
        spyOn(_moveRampLineService, "manageRampLineMovement").and.returnValue(true);

        _moveRampLineService.manageDrag(targetCircleGroup);

        expect(targetCircleGroup.me.stepDataGroup.setTop).toHaveBeenCalledWith(targetCircleGroup.top + 48);  
        expect(_moveRampLineService.manageRampLineMovement).toHaveBeenCalled();

    });

    it("It should test manageRampLineMovement method", function() {

        var left = 100;
        var top = 30;
        var targetCircleGroup = {
            setTop: function() {},
            top: 12,
            left: 150,
            me: {
                scrollTop: 12,
                lowestScrollCoordinate: 12,
                stepDataGroup: {
                    setTop: function() {
                        
                    }
                }
            }
        };  

        var parentCircle = {
            runAlongEdge: function() {},
            runAlongCircle: function() {},
            temperatureDisplay: function() {},
            parent: {
                adjustRampSpeedPlacing: function() {}
            },
            gatherDataDuringRampGroup: {
                setTop: function() {}
            },
            model: {
                ramp: {
                    collect_data: 10
                }
            },
            next: {
                gatherDataDuringRampGroup: {
                    setTop: function() {}
                },
                model: {
                    ramp: {
                        collect_data: 10
                    }
                }
            },
            previous: {
                curve: {
                    previousOne: function() {}
                }
            },
            curve: {
                nextOne: function() {}
            },

        }; 

        spyOn(parentCircle.curve, "nextOne");
        spyOn(parentCircle.next.gatherDataDuringRampGroup, "setTop");
        spyOn(parentCircle, "runAlongEdge");
        spyOn(parentCircle.previous.curve, "previousOne");
        spyOn(parentCircle.gatherDataDuringRampGroup, "setTop");
        spyOn(parentCircle, "runAlongCircle");
        spyOn(parentCircle, "temperatureDisplay");
        spyOn(parentCircle.parent, "adjustRampSpeedPlacing");

        _moveRampLineService.manageRampLineMovement(left, top, targetCircleGroup, parentCircle);

        expect(parentCircle.curve.nextOne).toHaveBeenCalled();
        expect(parentCircle.next.gatherDataDuringRampGroup.setTop).toHaveBeenCalled();
        expect(parentCircle.runAlongEdge).toHaveBeenCalled();

        expect(parentCircle.previous.curve.previousOne).toHaveBeenCalled();
        expect(parentCircle.gatherDataDuringRampGroup.setTop).toHaveBeenCalled();
        expect(parentCircle.runAlongCircle).toHaveBeenCalled();
        expect(parentCircle.temperatureDisplay).toHaveBeenCalled();
        expect(parentCircle.parent.adjustRampSpeedPlacing).toHaveBeenCalled();
    });

    it("It should test manageRampLineMovement method when there is no collect_data provided", function() {

        var left = 100;
        var top = 30;
        var targetCircleGroup = {
            setTop: function() {},
            top: 12,
            left: 150,
            me: {
                scrollTop: 12,
                lowestScrollCoordinate: 12,
                stepDataGroup: {
                    setTop: function() {
                        
                    }
                }
            }
        };  

        var parentCircle = {
            runAlongEdge: function() {},
            runAlongCircle: function() {},
            temperatureDisplay: function() {},
            parent: {
                adjustRampSpeedPlacing: function() {}
            },
            gatherDataDuringRampGroup: {
                setTop: function() {}
            },
            model: {
                ramp: {
                    
                }
            },
            next: {
                gatherDataDuringRampGroup: {
                    setTop: function() {}
                },
                model: {
                    ramp: {
                        
                    }
                }
            },
            previous: {
                curve: {
                    previousOne: function() {}
                }
            },
            curve: {
                nextOne: function() {}
            },

        }; 

        spyOn(parentCircle.curve, "nextOne");
        spyOn(parentCircle.next.gatherDataDuringRampGroup, "setTop");
        spyOn(parentCircle, "runAlongEdge");
        spyOn(parentCircle.previous.curve, "previousOne");
        spyOn(parentCircle.gatherDataDuringRampGroup, "setTop");
        spyOn(parentCircle, "runAlongCircle");
        spyOn(parentCircle, "temperatureDisplay");
        spyOn(parentCircle.parent, "adjustRampSpeedPlacing");

        _moveRampLineService.manageRampLineMovement(left, top, targetCircleGroup, parentCircle);

        expect(parentCircle.curve.nextOne).toHaveBeenCalled();
        expect(parentCircle.next.gatherDataDuringRampGroup.setTop).toHaveBeenCalled();
        expect(parentCircle.runAlongEdge).not.toHaveBeenCalled();

        expect(parentCircle.previous.curve.previousOne).toHaveBeenCalled();
        expect(parentCircle.gatherDataDuringRampGroup.setTop).toHaveBeenCalled();
        expect(parentCircle.runAlongCircle).not.toHaveBeenCalled();
        expect(parentCircle.temperatureDisplay).toHaveBeenCalled();
        expect(parentCircle.parent.adjustRampSpeedPlacing).toHaveBeenCalled();
    });
});