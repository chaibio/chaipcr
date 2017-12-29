describe("Testing stepHoldTime", function() {

   var _editMode, _stepHoldTimeService, stepHoldTime, ht;

   beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128,
                controlDistance: 4,
            });
        });

        inject(function($injector) {
            _editMode = $injector.get('editMode');
            _stepHoldTimeService = $injector.get('stepHoldTimeService');
            stepHoldTime = $injector.get('stepHoldTime');

            var model = {
                hold_time: 10,
                pause: false
            };

            var parent = {

            };

            var $scope = {

            };

            ht = new stepHoldTime(model, parent, $scope);
        });
   });

   it("It should test stepHoldTime return value", function() {

        console.log(ht);
        expect(ht.text).toEqual('00:10');
        expect(ht.fill).toEqual('black');
        expect(ht.top).toEqual(0);
        expect(ht.left).toEqual(60);
        expect(ht.fontSize).toEqual(20);
        expect(ht.originX).toEqual("left");
        expect(ht.originY).toEqual('top');
        expect(ht.fontFamily).toEqual('dinot');
        expect(ht.selectable).toEqual(false);
        expect(ht.hasBorder).toEqual(false);
        expect(ht.editingBorderColor).toEqual('#FFB300');
        expect(ht.type).toEqual('holdTimeDisplay');
        expect(ht.name).toEqual('holdTimeDisplayText');
        expect(ht.visible).toEqual(true);
        
   });
});