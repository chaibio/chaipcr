describe("Testing move-stage-indicator", function() {
  var _moveStageName, _moveStageType, _moveStageRectangle,
   _moveStageCoverRect, _moveStageIndicatorRectangleGroup, _moveStageIndicatorGroup, indicator, me, _moveStageIndicator;

   beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});

        });

        inject(function($injector) {

            _moveStageName = $injector.get('moveStageName');
            _moveStageType = $injector.get('moveStageType');
            _moveStageRectangle = $injector.get('moveStageRectangle');
            _moveStageCoverRect = $injector.get('moveStageCoverRect');
            _moveStageIndicatorRectangleGroup = $injector.get('moveStageIndicatorRectangleGroup');
            _moveStageIndicatorGroup = $injector.get('moveStageIndicatorGroup');
            _moveStageIndicator = $injector.get('moveStageIndicator');

            

        });

        me = {

        };

        indicator = new _moveStageIndicator(me);

    });


  /*beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStageIndicator;

  beforeEach(inject(function(moveStageIndicator) {

    var me = {
    };
    _moveStageIndicator = new moveStageIndicator(me);
  })); */

  it("It should check if moveStageIndicator has stageName", function() {
    expect(indicator.stageName).toEqual(jasmine.any(Object));
  });

  it("It should check if moveStageIndicator has stageType", function() {
    expect(indicator.stageType).toEqual(jasmine.any(Object));
  });

  it("It should check if moveStageIndicator.stageType text property", function() {
    expect(indicator.stageType.text).toEqual("HOLDING");
  });

  it("It should check if moveStageIndicator.stageName text property", function() {
    expect(indicator.stageName.text).toEqual("STAGE 2");
  });
  
  it("It should check me object", function() {

      /*me = {
        imageobjects: {
          "drag-stage-image.png": {

          }
        }
      };

      _moveStageName = function() {};

      _moveStageType = function() {};

      _moveStageCoverRect = function() {};

      _moveStageRectangle = function() {};
      
      _moveStageIndicatorRectangleGroup = function() {
        return {

        };
      };
      _moveStageIndicatorGroup = function() {
        return {

        };
      };
      
      indicator = new _moveStageIndicator(me);

      expect(me.imageobjects["drag-stage-image.png"].originX).toEqual("left"); */

  });
});
