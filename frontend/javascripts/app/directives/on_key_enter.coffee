# Usage:
#   <input on-key-enter="expression()">


window.ChaiBioTech.ngApp.directive 'onKeyEnter', [
  ->
    restrict: 'EA'
    scope:
      onKeyEnter: '&'
    link: ($scope, elem) ->
      elem.bind 'keypress keydown', (e) ->
        if e.which is 13
          $scope.$apply ->
            $scope.onKeyEnter()

          e.preventDefault()
]