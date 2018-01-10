describe("Testing textChanged", function() {

    var textChanged, C = {}, $scope = {}, that = {};

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            textChanged = $injector.get('textChanged');

            textChanged.canvas = {
                on: function() {

                }
            };

            textChanged.init(C, $scope, that);
        });
    });

    it("It should test init method", function() {

        textChanged.canvas = {
            on: function() {

            }
        };

        spyOn(textChanged.canvas, "on");

        textChanged.init(C, $scope, that); 

        expect(textChanged.canvas.on).toHaveBeenCalled();

    });

    it("It should test init method and on event", function() {

        var evt = {};

        textChanged.canvas = {
            on: function(arg1, callback) {
                callback(evt);
            }
        };

        C.canvas = {
            renderAll: function() {}
        };

        that.canvas = {
            getActiveObject: function() {
                return {
                    trigger: function() {

                    },
                    getText: function() {
                        return "Hai\n";
                    }
                };
            }
        };

        spyOn(that.canvas, "getActiveObject").and.callThrough();
        spyOn(C.canvas, "renderAll");

        textChanged.init(C, $scope, that);

        expect(that.canvas.getActiveObject).toHaveBeenCalled();
        expect(C.canvas.renderAll).toHaveBeenCalled();

    });

    it("It should test init method when text doesnt contain /\n/", function() {

        expect(1).toEqual(1);

        var evt = {};

        textChanged.canvas = {
            on: function(arg1, callback) {
                callback(evt);
            }
        };

        C.canvas = {
            renderAll: function() {}
        };

        that.canvas = {
            getActiveObject: function() {
                return {
                    trigger: function() {

                    },
                    getText: function() {
                        return "Hai";
                    }
                };
            }
        };

        spyOn(that.canvas, "getActiveObject").and.callThrough();
        spyOn(C.canvas, "renderAll");

        textChanged.init(C, $scope, that);

        expect(that.canvas.getActiveObject).toHaveBeenCalled();
        expect(C.canvas.renderAll).not.toHaveBeenCalled();
    });

});