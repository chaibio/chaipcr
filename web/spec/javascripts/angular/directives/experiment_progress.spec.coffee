describe 'ExperimentProgress Directive', ->

  beforeEach ->

    module 'ChaiBioTech'

    module ($provide) ->
      statusMock =
        fetch: (cb) ->
          cb {}

      $provide.value 'Status', statusMock

      return

    inject ($injector) ->
      @rootScope = $injector.get '$rootScope'
      @scope = @rootScope.$new()
      $compile = $injector.get '$compile'
      @Status = $injector.get 'Status'
      @StatusQuerySpy = spyOn(@Status, 'fetch').and.callThrough()
      @template= angular.element '<div experiment-progress></div>'
      @compiled = $compile(@template)(@scope)
      @scope.$digest()
      @isolatedScope = @compiled.isolateScope()

  it 'should fetch status', ->
    expect(@StatusQuerySpy).toHaveBeenCalled()
    expect(@isolatedScope.data).toBeDefined()


