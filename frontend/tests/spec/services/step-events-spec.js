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
});