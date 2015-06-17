describe 'ToggleSidemenu Directive', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->
      @rootScope = $injector.get '$rootScope'
      @scope = @rootScope.$new()
      $compile = $injector.get '$compile'
      @template = angular.element '<a toggle-sidemenu>asdf</a>'
      @compiled = $compile(@template)(@scope)
      @scope.$digest()

      @broadcastSpy = spyOn(@rootScope, '$broadcast').and.callThrough()

  it 'should broadcast "sidemenu:toggle"', ->
    @template.click()
    @scope.$apply()
    expect(@broadcastSpy).toHaveBeenCalled()