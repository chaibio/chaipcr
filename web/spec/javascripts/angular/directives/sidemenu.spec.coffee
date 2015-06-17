describe 'Sidemenu Directive', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->

      @rootScope = $injector.get '$rootScope'
      @scope = @rootScope.$new();
      @compile = $injector.get '$compile'
      @template = angular.element '<side-menu></side-menu>'
      @compiled = @compile(@template)(@scope)
      @scope.$digest()
      @isolatedScope = @compiled.isolateScope()

  it 'should not show by default', ->
    expect(@template.hasClass 'ng-hide').toBe true

  it 'should open on $rootScope.$broadcast("sidemenu:open")', ->
    @rootScope.$broadcast('sidemenu:open');
    @isolatedScope.$apply()
    expect(@template.hasClass 'ng-hide').toBe false

  it 'should close on $rootScope.$broadcast("sidemenu:close")', ->
    @isolatedScope.open = true
    @isolatedScope.$apply()
    expect(@template.hasClass 'ng-hide').toBe false

    @rootScope.$broadcast('sidemenu:close');
    @isolatedScope.$apply()
    expect(@template.hasClass 'ng-hide').toBe true

  it 'should toggle side menu', ->
    @isolatedScope.open = true
    @isolatedScope.$apply()
    @rootScope.$broadcast('sidemenu:toggle');
    @isolatedScope.$apply()
    expect(@template.hasClass 'ng-hide').toBe true

    @rootScope.$broadcast('sidemenu:toggle');
    @isolatedScope.$apply()
    expect(@template.hasClass 'ng-hide').toBe false