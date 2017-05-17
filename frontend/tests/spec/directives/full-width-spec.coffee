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
    expect(@directive.css('width')).toBe(@WindowWrapper.width() + 'px')

  it 'should resize when window size changes', ->
    spyOn(@WindowWrapper, 'width').and.callFake -> return 3000
    @scope.$broadcast('window:resize')
    expect(@directive.css('width')).toBe('3000px')

  it 'should use min-width', ->
    spyOn(@WindowWrapper, 'width').and.callFake -> return 1234
    @directive = @compile(angular.element('<div full-width use-min="true"></div>'))(@scope)
    @scope.$digest()
    expect(@directive.css('min-width')).toBe('1234px')

  it 'should use max-width', ->
    spyOn(@WindowWrapper, 'width').and.callFake -> return 1234
    @directive = @compile(angular.element('<div full-width use-max="true"></div>'))(@scope)
    @scope.$digest()
    expect(@directive.css('max-width')).toBe('1234px')

  it 'should have offset', ->
    spyOn(@WindowWrapper, 'width').and.callFake -> return 1234
    @directive = @compile(angular.element('<div full-width offset="234"></div>'))(@scope)
    @scope.$digest()
    expect(@directive.css('width')).toBe('1000px')

