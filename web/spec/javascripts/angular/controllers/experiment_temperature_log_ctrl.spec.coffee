
describe 'ExperimentTemperatureLog Controller', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->

      @rootScope = $injector.get '$rootScope'
      @scope = @rootScope.$new()
      @controller = $injector.get '$controller'

      @Experiment =
        getTemperatureData: (expId, opts) ->
          success: (cb) ->
            cb []

      @stateParams =
        expId: 1
        starttime: 0
        endtime: null
        resolution: 1000

      @fetchSpy = spyOn(@Experiment, 'getTemperatureData').and.callThrough()

      @ctrl = @controller 'ExperimentTemperatureLogCtrl',
        '$scope' : @scope
        'Experiment' : @Experiment
        '$stateParams': @stateParams


  it 'should fetch experment temperature data', ->
    expect(@fetchSpy).toHaveBeenCalledWith @stateParams.expId, @stateParams
    expect(@scope.temperatureData).toEqual [];
