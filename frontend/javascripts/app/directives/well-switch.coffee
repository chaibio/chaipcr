class WellSwitch

  HEIGHT: 210
  COL_COUNT: 8
  ROW_COUNT: 4
  COL_HEADER_FONT_SIZE: 12
  COL_HEADER_PADDING: 10
  ROW_HEADER_FONT_SIZE: 30
  ROW_HEADER_WIDTH: 15
  COL_HEADER_HEIGHT: 10

  BORDER_TOP_SIZE: 2

  constructor: (@elem, @state) ->
    @init()

  init: ->
    @width = @elem.parentElement.offsetWidth
    @height = @HEIGHT
    
    d3.select(@elem).selectAll('*').remove()
    @svg = d3.select(@elem).append('svg')
              .attr 'width', @width
              .attr 'height', @height

    @drawColumnHeaders()
    #@drawRowHeaders()
    #@drawCells()

  drawColumnHeaders: ->
    @svg.selectAll('.g-column-header').remove()
    @svg.select('.col-header-border-top').remove()

    col = [1..@COL_COUNT]
    
    borderTop = @svg.append('g')
                .attr 'class', 'col-header-border-top'
                .append 'rect'
                .attr 'x', 0
                .attr 'width', @width
                .attr 'y', 0
                .attr 'height', @BORDER_TOP_SIZE
                .attr 'fill', '#ccc'

    g = @svg.selectAll('g.g-column-header')
          .data(col)
          .enter()
          .append('g')
          .attr 'class', 'g-column-header'

    g.append('rect')
      .attr 'y', @BORDER_TOP_SIZE
      .attr 'width', =>
        @getCellWidth()
      .attr 'x', (i) =>
        @getColHeaderX(i)
      .attr 'height', @COL_HEADER_FONT_SIZE + @COL_HEADER_PADDING * 2
      .attr 'fill', '#fff'
      .attr 'stroke-width', 1
      .attr 'stroke', '#ccc'

    g.append('text').text (d) -> if d is 0 then '' else d
      .attr 'x', (i) =>
        @getColHeaderX(i) + (@getCellWidth() / 2) - (@COL_HEADER_FONT_SIZE / 2)
      .attr 'width', (i) => @getColHeaderWidth(i)
      .attr 'fill', '#000'
      .attr 'y', @COL_HEADER_FONT_SIZE + @BORDER_TOP_SIZE + @COL_HEADER_PADDING
      .attr 'font-size', @COL_HEADER_FONT_SIZE

  getColHeaderX: (i) ->
    ((@width - @ROW_HEADER_WIDTH) / @COL_COUNT) * (i - 1) + @ROW_HEADER_WIDTH

  getColHeaderWidth: (i) ->
    @getCellWidth()

  getCellWidth: ->
    (@width - @ROW_HEADER_WIDTH) / @COL_COUNT

  drawRowHeaders: ->
    @svg.selectAll('.g-row-header').remove()
    rows = [1..@ROW_COUNT]

    g = @svg.selectAll('g.g-row-header')
        .data(rows)
        .enter()
        .append('g')
          

window.ChaiBioTech = window.ChaiBioTech || {}
window.ChaiBioTech.WellSwitch = WellSwitch

