describe 'Login Controller', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->
      @rootScope = $injector.get '$rootScope'
      @scope = @rootScope.$new()
      $controller = $injector.get '$controller'
      @state =
        go: jasmine.createSpy()

      @ctrl = $controller 'LoginCtrl',
        '$scope': @scope
        '$state': @state

  it 'should be able to login', ->
    @ctrl.login()
    expect(@state.go).toHaveBeenCalledWith 'home'