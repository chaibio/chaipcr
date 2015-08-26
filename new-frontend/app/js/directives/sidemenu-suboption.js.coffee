window.ChaiBioTech.ngApp.directive 'sidemenuSuboption', [
  '$compile'
  '$templateCache'
  '$rootScope'
  ($compile, $templateCache, $rootScope) ->

    restrict: 'EA'
    scope:
      menuTemplate: '@'
    link: ($scope, elem) ->

      template = $templateCache.get $scope.menuTemplate
      compiled = $compile(template)($scope.$parent)
      arrow = elem.find('.arrow-right')

      elem.click ->
        $rootScope.$broadcast('submenu:toggle', compiled, elem)
        $rootScope.$apply()

]