
describe 'Home Controller', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->

      @rootScope = $injector.get '$rootScope'
      @scope = @rootScope.$new()
      @controller = $injector.get '$controller'

      @Experiment = class Experiment
        constructor: (obj) ->
        @query: (cb) ->
          cb [id:1]
        $save: (cb) ->
          cb null

      @fetchSpy = spyOn(@Experiment, 'query').and.callThrough()

      @ctrl = @controller 'HomeCtrl',
        '$scope' : @scope
        'Experiment' : @Experiment


  it 'should fetch experments', ->
    expect(@fetchSpy).toHaveBeenCalled()
    expect(@scope.experiments.length).toBeGreaterThan 0

  it 'should save experiment', ->
    fetchSpy = spyOn(@ctrl, 'fetchExperiments').and.callThrough()
    @ctrl.newExperiment()
    expect(fetchSpy).toHaveBeenCalled()
