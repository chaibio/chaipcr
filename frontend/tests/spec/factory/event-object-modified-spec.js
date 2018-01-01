describe("Testing object modified event", function() {

    var objectModified, that, C, $scope, _ExperimentLoader;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            objectModified = $injector.get('objectModified');
            _ExperimentLoader = $injector.get("ExperimentLoader");

            that = {};
            
            C = {
                canvas: {
                    renderAll: function() {}
                }
            };

            $scope = {};

            objectModified.canvas = {
                on: function() {}
            };

            objectModified.init(C, $scope, that);
            
        });

    });


    it("It should test init method", function() {

        spyOn(objectModified.canvas, "on");

        objectModified.init(C, $scope, that);

        expect(objectModified.canvas.on).toHaveBeenCalled();
    });

    describe("It should test switch statements", function() {

        it("It should test controlCircleGroup case", function() {

            var evt = {
                target: {
                    name: "controlCircleGroup"
                }
            };

            _ExperimentLoader.changeTemperature = function() {
                return {
                    then: function(callBack) {
                        var data = {
                            message: "Works"
                        };
                        callBack(data);
                    }
                };
            };

            objectModified.canvas = {
                on: function(arg1, callBack) {
                    callBack(evt);
                }
            };

            spyOn(_ExperimentLoader, "changeTemperature").and.callThrough();

            objectModified.init(C, $scope, that);

            expect(_ExperimentLoader.changeTemperature).toHaveBeenCalled();

        });

        it("It should test moveStage test case", function() {

            var evt = {
                target: {
                    name: "moveStage",
                    parent: {

                    }
                }
            };

            objectModified.canvas = {
                on: function(arg1, callBack) {
                    callBack(evt);
                }
            };

            spyOn(C.canvas, "renderAll");

            objectModified.init(C, $scope, that);

            expect(C.canvas.renderAll).toHaveBeenCalled();

        });
    });
});