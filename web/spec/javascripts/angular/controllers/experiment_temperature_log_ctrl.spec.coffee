
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

      @state = go: jasmine.createSpy()

      @stateParams =
        expId: 1
        resolution: 1000

      @fetchSpy = spyOn(@Experiment, 'getTemperatureData').and.callThrough()

      @ctrl = @controller 'ExperimentTemperatureLogCtrl',
        '$scope' : @scope
        'Experiment' : @Experiment
        '$stateParams': @stateParams
        'ChartData': @ChartData
        '$state'  : @state

  it 'should have angular-chart options', ->
    expect(@scope.options).toEqual
      pointDot: false
      datasetFill: false

  it 'should fetch experiment temperature data', ->
    data = @ChartData.temperatureLogs.toAngularCharts()
    expect(@fetchSpy).toHaveBeenCalledWith @stateParams.expId, @stateParams
    expect(@scope.labels).toEqual data.elapsed_time;
    expect(@scope.series).toEqual ['Heat block zone 1', 'Heat block zone 2', 'Lid']
    expect(@scope.data).toEqual [
      data.heat_block_zone_1_temp
      data.heat_block_zone_2_temp
      data.lid_temp
    ]

  it 'should update chart when time elapsed changed', ->
    @scope.elapsed = 200
    @scope.elapsedChanged()
    expect(@state.go).toHaveBeenCalledWith 'expTemperatureLog', {
      expId: @stateParams.expId
      endtime: @scope.elapsed
    }, notify: false

    expect(@fetchSpy).toHaveBeenCalledWith @stateParams.expId, @stateParams
