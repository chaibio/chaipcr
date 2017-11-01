describe("Testing mouse-down events", function() {

    var mouseDown, _ExperimentLoader, _circleManager, _editMode, _movingStepGraphics, _correctNumberingService;
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

        var C = {}, that = {};

        mouseDown.init(C, that);

    });

   });
});