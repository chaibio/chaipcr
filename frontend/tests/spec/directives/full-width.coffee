describe 'Full Width Directive', ->

  beforeEach ->
    module 'ChaiBioTech', ($provide) ->
      mockCommonServices($provide)

    inject ($injector) ->
      @compile = $injector.get('$compile')
      @rootScope = $injector.get('$rootScope')
      @scope = @rootScope.$new()
      @WindowWrapper = $injector.get('WindowWrapper')

    @directive = @compile(angular.element('<div full-width></div>'))(@scope)
    @scope.$digest()

  it 'should have full width', ->
    expect(@directive.css('min-width')).toBe(@WindowWrapper.width() + 'px')

  it 'should resize when window size changes', ->
    spyOn(@WindowWrapper, 'width').and.callFake -> return 3000
    @scope.$broadcast('window:resize')
    expect(@directive.css('min-width')).toBe('3000px')

  it 'should force full width', ->
    spyOn(@WindowWrapper, 'width').and.callFake -> return 1234
    @directive = @compile(angular.element('<div full-width force="true"></div>'))(@scope)
    @scope.$digest()
    expect(@directive.width()).toBe(1234)
    expect(@directive.css('width')).toBe('1234px')

