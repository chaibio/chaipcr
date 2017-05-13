describe 'Ampli Slider directive', ->

  beforeEach ->
    module 'ChaiBioTech', ($provide) ->
      mockCommonServices($provide)

    inject ($injector) ->
      @rootScope = $injector.get '$rootScope'
      @compile = $injector.get '$compile'
      @timeout = $injector.get '$timeout'
      @scope = @rootScope.$new()
      @TextSelection = $injector.get 'TextSelection'

    @width = 200
    @scope.slider = 0
    template = "<div><ampli-slider ng-model=\"slider\" style=\"width:#{@width}px\"></ampli-slider></div>"

    @compiled = @compile(template)(@scope)
    @directive = @compiled.find('.ampli-slider')
    @svg = @directive.find('svg')
    @background = @directive.find('rect').eq(0)
    @offset = @directive.find('rect').eq(1)
    @handleShadow = @directive.find('circle').eq(0)
    @handle = @directive.find('circle').eq(1)
    @scope.$digest()
    @timeout.flush()

  it 'should have slider elements', ->
    expect(@svg.length).toBe(1)
    expect(@background.length).toBe(1)
    expect(@offset.length).toBe(1)
    expect(@handleShadow.length).toBe(1)
    expect(@handle.length).toBe(1)

  it 'should disable text selection on mousedown', ->
    spyOn(@TextSelection, 'disable')
    @handle.triggerHandler(type: 'mousedown')
    expect(@TextSelection.disable).toHaveBeenCalled()

  it 'should enable text selection on mouseup', ->
    spyOn(@TextSelection, 'enable')
    @scope.$broadcast('window:mouseup')
    expect(@TextSelection.enable).toHaveBeenCalled()

  it 'should move', ->
    px = 50

    circleR = 7
    circleStroke = 4
    circleShadowR = circleR + (circleStroke/2) + 0.5

    oldPageX = 0
    oldOffsetWidth = @offset.attr('width') * 1
    oldHolderCX = @handle.attr('cx') * 1
    oldHolderShadowCX = @handleShadow.attr('cx') * 1

    @handle.triggerHandler(type: 'mousedown', pageX: 0)
    @scope.$broadcast('window:mousemove', pageX: px)
    @scope.$digest()
    expect(@handleShadow.attr('cx')).toBe('59.5')
    expect(@handle.attr('cx')).toBe('59.5')

    minOffsetWidth = circleR - circleStroke/2
    maxOffsetWidth = @width - circleR * 2
    x = ((oldOffsetWidth + px) - minOffsetWidth)/(maxOffsetWidth - minOffsetWidth)
    expect(@scope.slider).toBe(-Math.sqrt(1-Math.pow(x, 2)) + 1)

  it 'should be able to resize', ->
    @scope.slider = 0.5
    @scope.$digest()
    @width = 100
    @directive.css(width: @width)
    @scope.$broadcast 'window:resize'
    @scope.$broadcast 'window:resize'
    expect(@svg.attr('width')).toBe('0')
    expect(@background.attr('width')).toBe('0')
    expect(@offset.attr('width')).toBe('0')
    expect(@handleShadow.attr('cx')).toBe('0')
    expect(@handle.attr('cx')).toBe('0')
    @timeout.flush()
    expect(@svg.attr('width')).toBe("#{@width}")
    expect(@background.attr('width')).toBe("#{@width}")
    expect(@offset.attr('width')).not.toBe('0')
    expect(@handleShadow.attr('cx')).not.toBe('0')
    expect(@handle.attr('cx')).not.toBe('0')

  describe 'Root element', ->

    it 'should be full-width', ->
      expect(@directive.width()).toBe(@width)

    it 'should set its parent element height to 20px', ->
      expect(@directive.parent().height()).toBe(20)

  describe 'Root SVG element', ->

    it 'should be full-width', ->
      expect(@svg.attr('width')).toBe("#{@width}")

    it 'should be 20px tall', ->
      expect(@svg.attr('height')).toBe('20')

    it 'should have alignment middle', ->
      expect(@svg.attr('alignment-baseline')).toBe('middle')

  describe 'Background element', ->
    it 'should be color #ccc', ->

    it 'should be full-width', ->
      expect(@background.attr('width')).toBe("#{@width}")

    it 'should be 5px tall', ->
      expect(@background.attr('height')).toBe('5')

