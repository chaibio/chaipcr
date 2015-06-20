
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

      @ChartData =
        temperatureLogs:
          toAngularCharts: ->
            elapsed_time: 'elapsed_time'
            heat_block_zone_1_temp: 'heat_block_zone_1_temp'
            heat_block_zone_2_temp: 'heat_block_zone_2_temp'
            lid_temp: 'lid_temp'

      @stateParams =
        expId: 1
        resolution: 1000

      @fetchSpy = spyOn(@Experiment, 'getTemperatureData').and.callThrough()

      @ctrl = @controller 'ExperimentTemperatureLogCtrl',
        '$scope' : @scope
        'Experiment' : @Experiment
        '$stateParams': @stateParams
        'ChartData': @ChartData

  it 'should have angular-chart options', ->
    expect(@scope.options).toEqual
      pointDot: false
      datasetFill: false

  it 'should have default starttime and endtime', ->
    expect(@stateParams.starttime).toBe 0
    expect(@stateParams.endtime).toBe (60 * 200)

  it 'should fetch experiment temperature data', ->
    data = @ChartData.temperatureLogs.toAngularCharts()
    expect(@fetchSpy).toHaveBeenCalledWith @stateParams.expId, jasmine.any Object
    expect(@scope.labels).toEqual data.elapsed_time;
    expect(@scope.series).toEqual ['Heat block zone 1', 'Heat block zone 2', 'Lid']
    expect(@scope.data).toEqual [
      data.heat_block_zone_1_temp
      data.heat_block_zone_2_temp
      data.lid_temp
    ]
