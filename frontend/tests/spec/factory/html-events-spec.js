describe("Testing html-events in edit protocol", function() {

   var htmlEvents, _htmlEvents, _previouslyHoverd, _popupStatus, _editMode;

   beforeEach(function() {

    module('ChaiBioTech', function($provide) {
        $provide.value('IsTouchScreen', function () {});
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

   
});