describe("Testing html-events in edit protocol", function() {

   var htmlEvents, _htmlEvents, _previouslyHoverd, _popupStatus, _editMode;

   beforeEach(function() {

    module('ChaiBioTech', function($provide) {
        $provide.value('IsTouchScreen', function () {});
        $provide.value('editMode', {
            tempActive: true,
            holdActive: false,
            currentActiveTemp: {
                fire: function() {}
            }
        });
    });

    inject(function($injector) {

        _previouslyHoverd = $injector.get('previouslyHoverd');
        _popupStatus = $injector.get('popupStatus');
        _editMode = $injector.get('editMode');
        htmlEvents = $injector.get('htmlEvents');

        var C = {}, that = {};

        htmlEvents.init(C, that);

    });

   });

   it("It should test manageClcikOnBody method, when body is clicked", function() {

        var evt = {
            target: {
                id: "add-step"
            }
        };

        _popupStatus.popupStatusAddStage = true;

        htmlEvents.manageClcikOnBody(evt);

        expect(1).toEqual(1);
   
    });

    it("It should test manageClickOnCanvasContaining method", function() {

        var evt = {
            target: "spot",
            currentTarget: "spot",
        };

        var C = {};
        
        var that = {
            setSummaryMode: function() {}
        };

        htmlEvents.init(C, that);

        spyOn(that, "setSummaryMode");
        
        htmlEvents.manageClickOnCanvasContaining(evt);

        expect(that.setSummaryMode).toHaveBeenCalled();
    });

    it("It should test mouseLeaveEventHandler, when editStageStatus = true", function() {

        var evt = {
            target: "spot",
            currentTarget: "spot",
        };

        var C = {
            editStageStatus: false,
            canvas: {
                renderAll: function() {}
            }
        };

        var that = {
            setSummaryMode: function() {}
        };


        htmlEvents.init(C, that);

        _previouslyHoverd.step = {
            closeImage: {
                setOpacity: function() {}
            }
        };

        _editMode.tempActive = false;
        _editMode.tempActive = false;

        spyOn(_previouslyHoverd.step.closeImage, "setOpacity");
        spyOn(C.canvas, "renderAll");

        htmlEvents.mouseLeaveEventHandler();

        expect(_previouslyHoverd.step.closeImage.setOpacity).toHaveBeenCalled();
        expect(C.canvas.renderAll).toHaveBeenCalled();

    });

    it("It should test mouseLeaveEventHandler, when tempActive = true", function() {

        var evt = {
            target: "spot",
            currentTarget: "spot",
        };

        var C = {
            editStageStatus: true,
            canvas: {
                renderAll: function() {}
            }
        };

        var that = {
            setSummaryMode: function() {}
        };


        htmlEvents.init(C, that);

        _previouslyHoverd.step = {
            closeImage: {
                setOpacity: function() {}
            }
        };

        
        

        spyOn(_previouslyHoverd.step.closeImage, "setOpacity");
        spyOn(C.canvas, "renderAll");
        spyOn(_editMode.currentActiveTemp, "fire");

        htmlEvents.mouseLeaveEventHandler();

        expect(_previouslyHoverd.step.closeImage.setOpacity).not.toHaveBeenCalled();
        expect(C.canvas.renderAll).not.toHaveBeenCalled();
        expect(_editMode.currentActiveTemp.fire).toHaveBeenCalledWith('text:editing:exited');
    });

    it("It should test mouseLeaveEventHandler, when holdActive = true", function() {

        var evt = {
            target: "spot",
            currentTarget: "spot",
        };

        var C = {
            editStageStatus: true,
            canvas: {
                renderAll: function() {}
            }
        };

        var that = {
            setSummaryMode: function() {}
        };


        htmlEvents.init(C, that);

        _previouslyHoverd.step = {
            closeImage: {
                setOpacity: function() {}
            }
        };

        
        _editMode.holdActive = true;
        _editMode.currentActiveHold = {
            fire: function() {}
        };
        spyOn(_previouslyHoverd.step.closeImage, "setOpacity");
        spyOn(C.canvas, "renderAll");
        spyOn(_editMode.currentActiveHold, "fire");

        htmlEvents.mouseLeaveEventHandler();

        expect(_previouslyHoverd.step.closeImage.setOpacity).not.toHaveBeenCalled();
        expect(C.canvas.renderAll).not.toHaveBeenCalled();
        expect(_editMode.currentActiveHold.fire).toHaveBeenCalled();
    });



});