describe("Testing stepTemperature", function() {

   var _editMode, _stepTemperatureService, stepTemperature, st;

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
            _stepTemperatureService = $injector.get('stepTemperatureService');
            stepTemperature = $injector.get('stepTemperature');

            var model = {
                hold_time: 10,
                temperature: 40,
                pause: false
            };

            var parent = {

            };

            var $scope = {

            };

            st = new stepTemperature(model, parent, $scope);
        });
   });

   it("It should test stepTemperature return value", function() {

        expect(st.text).toEqual('40.0º');
        expect(st.fill).toEqual('black');
        expect(st.top).toEqual(0);
        expect(st.left).toEqual(0);
        expect(st.fontSize).toEqual(20);
        expect(st.originX).toEqual("left");
        expect(st.originY).toEqual('top');
        expect(st.fontFamily).toEqual('dinot-bold');
        expect(st.selectable).toEqual(false);
        expect(st.hasBorder).toEqual(false);
        expect(st.editingBorderColor).toEqual('#FFB300');
        expect(st.type).toEqual('temperatureDisplay');
        expect(st.name).toEqual('temperatureDisplayText');
        expect(st.visible).toEqual(true);
        
   });

   
   it("It should test editingExited method", function() {

        _editMode.tempActive = true;

        _stepTemperatureService.postEdit = function() {};

        spyOn(_stepTemperatureService, "postEdit");

        st.editingExited();

        expect(_stepTemperatureService.postEdit).toHaveBeenCalled();
   });

   it("It should test editingExited method when holdActive is false", function() {

        _editMode.tempActive = false;

        _stepTemperatureService.postEdit = function() {

        };

        spyOn(_stepTemperatureService, "postEdit");

        st.editingExited();

        expect(_stepTemperatureService.postEdit).not.toHaveBeenCalled();
   });
});