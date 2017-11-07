describe("Testing mouseOver events", function() {

    var mouseOver, C , $scope = {}, that = {}, _previouslyHoverd;

    beforeEach(function() {
        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            mouseOver = $injector.get('mouseOver');
            _previouslyHoverd = $injector.get('previouslyHoverd');

            mouseOver.canvas = {
                on: function() {}
            };

            that = {
                canvas: {
                    hoverCursor: "anything"
                }
            };

            C = {
                editStageStatus: true,
                canvas: {
                    renderAll: function() {}
                }
            };

            mouseOver.init(C, $scope, that);

        });

    });

    it("It should test init method", function() {

        spyOn(mouseOver.canvas,"on");

        mouseOver.init(C, $scope, that);

        expect(mouseOver.canvas.on).toHaveBeenCalled();
    });

    describe("It should test mouseOverHandler method, in different conditions", function() {

        it("It should test mouseOverHandler method when no target", function() {

            var evt = {
                target: null
            };

            var retVal = mouseOver.mouseOverHandler(evt);

            expect(retVal).toEqual(false);
        });

        it("It should test mouseOverHandler method when target is stepGroup", function() {

            var evt = {
                target: {
                    name: "stepGroup"
                }
            };

            spyOn(mouseOver, "stepGroupHoverHandler").and.returnValue(true);

            mouseOver.mouseOverHandler(evt);

            expect(mouseOver.stepGroupHoverHandler).toHaveBeenCalled();

        });

        it("It should test controlCircleGroup case", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "controlCircleGroup"
                }
            };

            mouseOver.mouseOverHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("pointer");
        });

        it("It should test moveStep case", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "moveStep"
                }
            };

            mouseOver.mouseOverHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("pointer");

        });
        
        it("It should test moveStage case", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "moveStage"
                }
            };

            mouseOver.mouseOverHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("pointer");

        });

        it("It should test deleteStepButton case", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "deleteStepButton"
                }
            };

            mouseOver.mouseOverHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("pointer");

        });

    });

    describe("Testing stepGroupHoverHandler and conditions", function() {

        it("It should test stepGroupHoverHandler method, when editStageStatus = true", function() {

            var evt = {
                target: {
                    me: {
                        closeImage: {
                            animate: function() {

                            }
                        }
                    }
                }
            };

            spyOn(C.canvas, "renderAll");
            spyOn(evt.target.me.closeImage, "animate");

            mouseOver.stepGroupHoverHandler(evt);
            
            expect(C.canvas.renderAll).not.toHaveBeenCalled();
            expect(evt.target.me.closeImage.animate).not.toHaveBeenCalled();
        });

        it("It should test stepGroupHoverHandler method, editStageStatus = false", function() {

            var evt = {
                target: {
                    me: {
                        closeImage: {
                            animate: function() {

                            }
                        }
                    }
                }
            };

            C.editStageStatus = false;

            spyOn(C.canvas, "renderAll");
            spyOn(evt.target.me.closeImage, "animate");

            mouseOver.stepGroupHoverHandler(evt);

            expect(C.canvas.renderAll).toHaveBeenCalled();
            expect(evt.target.me.closeImage.animate).toHaveBeenCalled();

        });

        it("It should test stepGroupHoverHandle method, when editStageStatus = false and previouslyHoverd.step && (me.model.id !== previouslyHoverd.step.model.id", function() {

            var evt = {
                target: {
                    me: {
                        model: {
                            id:110
                        },
                        closeImage: {
                            animate: function() {

                            }
                        }
                    }
                }
            };

            _previouslyHoverd.step = {
                closeImage: {
                        animate: function() {

                        }
                    },
                model: {
                    id: 120
                }
            };

            C.editStageStatus = false;

            spyOn(C.canvas, "renderAll");
            spyOn(evt.target.me.closeImage, "animate");
            spyOn(_previouslyHoverd.step.closeImage, "animate");

            mouseOver.stepGroupHoverHandler(evt);

            expect(C.canvas.renderAll).toHaveBeenCalled();
            expect(evt.target.me.closeImage.animate).toHaveBeenCalled();
            expect(_previouslyHoverd.step.closeImage.animate).toHaveBeenCalled();

        });
    });

});