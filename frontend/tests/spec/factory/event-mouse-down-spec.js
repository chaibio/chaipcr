describe("Testing mouse-down events", function() {

    var mouseDown, _ExperimentLoader, _circleManager, _editMode, _movingStepGraphics, _correctNumberingService, C;
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

        _correctNumberingService = $injector.get('correctNumberingService');
        _movingStepGraphics = $injector.get('movingStepGraphics');
        _editMode = $injector.get('editMode');
        _circleManager = $injector.get('circleManager');
        _correctNumberingService = $injector.get('correctNumberingService');
        mouseDown = $injector.get('mouseDown');

        C = {
            canvas: {
                remove: function() {},
                add: function() {},
                renderAll: function() {},
                setActiveObject: function() {},
            }
        };
        var $scope = {}; 
        var that = {};

        // This is a little patch;
        mouseDown.canvas = {
            on: function() {}
        };
        mouseDown.init(C, $scope, that);

    });

   });


   it("It should test if init method call is alright", function() {
        expect(mouseDown.mouseDownHandler).toEqual(jasmine.any(Function));
   });

   it("It should test unHookGroup method", function() {

        var group = {
            _restoreObjectsState: function() {}
        };

        var items = [
            { index: 1 },
            { index: 2 },
            { index: 3 },
            { index: 4 }
        ];

        var index_to_remove = 1;

        spyOn(group, "_restoreObjectsState");
        spyOn(C.canvas, "remove");
        spyOn(C.canvas, "add");
        spyOn(C.canvas, "renderAll");

        mouseDown.unHookGroup(group, items, index_to_remove);

        expect(group._restoreObjectsState).toHaveBeenCalled();
        expect(C.canvas.remove).toHaveBeenCalled();
        expect(C.canvas.add).toHaveBeenCalledTimes(3);
        expect(C.canvas.renderAll).toHaveBeenCalled();
        expect(items.length).toEqual(3);
   });


   it("It should test startEditing method", function() {

        var textToBeEdited = {
            getSelectionStartFromPointer: function() {},
            moveCursorRightWithoutShift: function() {},
            enterEditing: function() {},
        };

        var evt = {};


        spyOn(textToBeEdited, "getSelectionStartFromPointer").and.returnValue(2);
        spyOn(textToBeEdited, "moveCursorRightWithoutShift");
        spyOn(textToBeEdited, "enterEditing");
        spyOn(C.canvas, "setActiveObject");

        mouseDown.startEditing(textToBeEdited, evt);

        expect(textToBeEdited.getSelectionStartFromPointer).toHaveBeenCalled();
        expect(textToBeEdited.moveCursorRightWithoutShift).toHaveBeenCalledTimes(2);
        expect(C.canvas.setActiveObject).toHaveBeenCalled();
   });


});