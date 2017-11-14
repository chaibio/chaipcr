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

            objectMoving.init(C, $scope, that);
        });

        it("It should test init method", function() {

            spyOn(objectMoving.canvas, "on");

            objectMoving.init(C, $scope, that);

            expect(objectMoving.canvas.on).toHaveBeenCalled();

        });

        describe("Testing switch cases", function() {

            it("It should test no evt.terget scenario", function() {

                var evt = {
                    target: null
                };

                objectMoving.canvas = {
                    on: function(arg1, callBack) {
                        callBack(evt);
                    }
                };

                var retVal = objectMoving.init(C, $scope, that);

                expect(retVal).toEqual(false);
            });
        });
    });

});