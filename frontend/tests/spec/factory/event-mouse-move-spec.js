describe("Testing mouse-move event", function() {
    var mouseMove, C, that, $scope;
    
    beforeEach(function() {

        module("ChaiBioTech", function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            
            mouseMove = $injector.get('mouseMove');

            C = {};
            that = {
                mouseDown: false,
                startDrag: 0,
                canvas: {
                    defaultCursor: "Wow"
                }
            };

            $scope = {
                $apply: function(callB) {
                    callB();
                },
                scrollWidth: 2000,
            };
            
            mouseMove.canvas = {
                on: function() {

                }
            };

            mouseMove.init(C, $scope, that);
            
        });
    });

    it("It should test init method", function() {

        spyOn(mouseMove.canvas, "on");

        mouseMove.init(C, $scope, that);

        expect(mouseMove.canvas.on).toHaveBeenCalled();    
    });

    it("It should test handleMouseMove method, when mouseDown is false", function() {

        var evt = {
            target: {},
            e: {
                clientX: 100,
                clientY: 150,
            }
        };

        spyOn($scope, "$apply");
        
        mouseMove.handleMouseMove(evt);

        expect($scope.$apply).not.toHaveBeenCalled();

    });

    it("It should test handleMouseMove method, when mouseDown is true", function() {

        var evt = {
            target: {},
            e: {
                clientX: 100,
                clientY: 150,
            }
        };

        that.mouseDown = true;

        spyOn($scope, "$apply");
        
        mouseMove.handleMouseMove(evt);

        expect($scope.$apply).not.toHaveBeenCalled();
        expect(that.canvas.defaultCursor).toEqual('ew-resize');
        expect(that.startDrag).toEqual(evt.e.clientX);

    });

    it("It should test handleMouseMove method, when mouseDown is true", function() {

        var evt = {
            target: {},
            e: {
                clientX: 100,
                clientY: 150,
            }
        };

        mouseMove.canvasContaining = {
            scrollLeft: function() {
                return 300;
            }
        };

        that.mouseDown = true;

        
        spyOn($scope, "$apply").and.callThrough();
        //spyOn(mouseMove.canvasContaining, "scrollLeft");

        mouseMove.handleMouseMove(evt);

        expect($scope.$apply).toHaveBeenCalled();
        expect(that.canvas.defaultCursor).toEqual('ew-resize');
        expect(that.startDrag).toEqual(evt.e.clientX);
        //expect(mouseMove.canvasContaining.scrollLeft).toHaveBeenCalled();
    });



});