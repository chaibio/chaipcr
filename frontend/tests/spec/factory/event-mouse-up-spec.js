describe("Testing mouse up events", function() {

    var mouseUp, that, C, $scope, _circleManager;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            mouseUp = $injector.get('mouseUp');

            _circleManager = $injector.get('circleManager');

            mouseUp.canvas = {
                on: function() {}
            };

            that = {
                canvas: {
                    hoverCursor: "anything"
                }
            };

            mouseUp.init(C, $scope, that);

        });
    });

    it("It should test init method", function() {

        spyOn(mouseUp.canvas, "on");
        mouseUp.init(C, $scope, that);
        expect(mouseUp.canvas.on).toHaveBeenCalled();
    });
});