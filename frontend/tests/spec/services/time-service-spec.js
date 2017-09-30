describe("Testing TimeService", function() {

    var _TimeService, _$rootScope;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {

            _TimeService = $injector.get('TimeService');
            _$rootScope = $injector.get('$rootScope');
        });


    });

    it("It should test convertToSeconds method", function() {

        var timeString = "1:2:3";
        var rVal = _TimeService.convertToSeconds(timeString);
        expect(rVal).toEqual(3723);
    });

    it("It should test convertToSeconds method, when second is invalid", function() {

        var timeString = "1:2:xx";
        var rVal = _TimeService.convertToSeconds(timeString);
        expect(rVal).toEqual(false);
    });

    it("It should test convertToSeconds method, when minute is invalid", function() {

        var timeString = "1:xx:3";
        var rVal = _TimeService.convertToSeconds(timeString);
        expect(rVal).toEqual(false);
    });

    it("It should test convertToSeconds method, when hour is invalid", function() {

        var timeString = "xx:2:3";
        var rVal = _TimeService.convertToSeconds(timeString);
        expect(rVal).toEqual(false);
    });
});