describe("Testing dots", function() {

    var dots, d;
    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});

        });

        inject(function($injector) {
            dots = $injector.get('dots');
        });
    });

    it("It should test getStageCordinates method", function() {

        var retV = dots.getStageCordinates();
        expect(retV.dot1).toEqual([1, 1]);
        expect(retV.dot2).toEqual([12, 1]);
        expect(retV.dot3).toEqual([6.5, 6]);
        expect(retV.dot4).toEqual([1, 10]);
        //expect(retV.dot5).toEqual(12, 10);
    });

    it("It should test stepStageMoveDots method", function() {

        var retV = dots.stepStageMoveDots();
        expect(retV).toEqual(jasmine.any(Array));
        expect(retV.length).toEqual(89);
    });

    it("It should test stepStageMoveDots method and its return value", function() {

        var retV = dots.stepStageMoveDots();
        
        expect(retV[0].radius).toEqual(2);
        expect(retV[0].fill).toEqual("black");
        expect(retV[0].left).toEqual(1);
        expect(retV[0].top).toEqual(1);
        expect(retV[0].selectable).toEqual(false);
        expect(retV[0].name).toEqual("stageDot");
        expect(retV[0].originX).toEqual("center");
        expect(retV[0].originY).toEqual("center");
        
    });

    it("It should test getStepCordinates method", function() {

        var retV = dots.getStepCordinates();
        expect(retV).toEqual(jasmine.any(Object));
        expect(retV.topDot9).toEqual(undefined);
        expect(retV.middleDot8).toEqual(undefined);
    });

    it("It should test prepareArray method", function() {

        var retV = dots.prepareArray(dots.getStepCordinates());
        
        expect(retV[0].radius).toEqual(2);
        expect(retV[0].width).toEqual(4);
        expect(retV[0].height).toEqual(4);
        expect(retV[0].left).toEqual(1);
        expect(retV[0].top).toEqual(1);
        expect(retV[0].selectable).toEqual(false);
        expect(retV[0].name).toEqual("stageDot");
        expect(retV[0].originX).toEqual("center");
        expect(retV[0].originY).toEqual("center");

    });

    it("It should test stepDots method", function() {

        spyOn(dots, "prepareArray").and.returnValue({});

        dots.stepDots();

        expect(dots.prepareArray).toHaveBeenCalled();
    });

    it("It should test stageDots method", function() {

        spyOn(dots, "prepareArray").and.returnValue({});

        dots.stageDots();

        expect(dots.prepareArray).toHaveBeenCalled();
    });

    it("It should test stepDotCordiantes and stageDotCordinates", function() {

        expect(dots.stepDotCordiantes).toEqual(jasmine.any(Object));
        expect(dots.stageDotCordinates).toEqual(jasmine.any(Object));
    });
});