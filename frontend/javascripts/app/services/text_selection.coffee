# avoid text selection when dragging the scrollbar

window.App.service 'TextSelection', [
  '$window'
  ($window) ->

    return new class TextSelection

      disable: ->
        $window.$(document.body).css
          'userSelect': 'none'

      enable: ->
        $window.$(document.body).css
          'userSelect': ''
]