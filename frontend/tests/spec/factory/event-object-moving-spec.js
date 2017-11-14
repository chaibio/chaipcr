describe("Testing object moving events", function() {

    var objectMoving, that = {}, C = {}, $scope = {}, _moveRampLineService;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            objectMoving = $injector.get('objectMoving');
            _moveRampLineService = $injector.get('moveRampLineService');


            objectMoving.canvas = {
                on: function() {}
            };

            $scope.step = {
                temperature: "100"
            };

            objectMoving.init(C, $scope, that);
        });

    });
        it("It should test init method", function() {

            spyOn(objectMoving.canvas, "on");

            objectMoving.init(C, $scope, that);

            expect(objectMoving.canvas.on).toHaveBeenCalled();

        });

        describe("Testing switch cases", function() {

            it("It should test no evt.terget scenario", function() {

                var evt = {
                    
                };

                objectMoving.canvas = {
                    on: function(arg1, callBack) {
                        callBack(evt);
                    }
                };

                var retVal = objectMoving.init(C, $scope, that);
                
                expect(retVal).toEqual(undefined);
            });

            it("It should test controlCircleGroup test case", function() {

                var evt = {
                    target: {
                        name: "controlCircleGroup",
                        me: {
                            model: {
                                temperature: 67,
                            }
                        }
                    }
                };

                _moveRampLineService.manageDrag = function() {};

                $scope.$apply = function(callBack) {
                    callBack();
                };

                objectMoving.canvas = {
                    on: function(arg1, callBack) {
                        callBack(evt);
                    }
                };

                spyOn(_moveRampLineService, "manageDrag");
                spyOn($scope, "$apply").and.callThrough();

                objectMoving.init(C, $scope, that);

                expect(_moveRampLineService.manageDrag).toHaveBeenCalled();
                expect($scope.$apply).toHaveBeenCalled();
                expect($scope.step.temperature).toEqual(67);
            });

            it("It should test moveStep test case, when if condition resolved true", function() {

                C.stepMoveLimit = 350;
                var evt = {
                    target: {
                        name: "moveStep",
                        left: 360,
                        setLeft: function() {}
                    }
                };

                objectMoving.canvas = {
                    on: function(arg1, callBack) {
                        callBack(evt);
                    }
                };

                spyOn(evt.target, "setLeft");

                objectMoving.init(C, $scope, that);

                expect(evt.target.setLeft).toHaveBeenCalled();

            });


            it("It should test moveStep test case, when if condition resolved false", function() {

                C.stepMoveLimit = 380;

                C.stepIndicator = {
                    onTheMove: function() {}
                };

                var evt = {
                    target: {
                        name: "moveStep",
                        left: 360,
                        setLeft: function() {}
                    }
                };

                objectMoving.canvas = {
                    on: function(arg1, callBack) {
                        callBack(evt);
                    }
                };

                spyOn(evt.target, "setLeft");
                spyOn(C.stepIndicator, "onTheMove");

                objectMoving.init(C, $scope, that);

                expect(evt.target.setLeft).not.toHaveBeenCalled();
                expect(C.stepIndicator.onTheMove).toHaveBeenCalled();
            });

        });
    
});