window.ChaiBioTech.ngApp.directive 'sidemenuSuboption', [
  '$compile'
  '$templateCache'
  '$rootScope'
  ($compile, $templateCache, $rootScope) ->

    restrict: 'EA'
    scope:
      menuTemplate: '@'
    link: ($scope, elem) ->

      elem.click ->
        template = $templateCache.get $scope.menuTemplate
        compiled = $compile(template)($scope.$parent)
        arrow = elem.find('.arrow-right')
        $rootScope.$broadcast('submenu:toggle', compiled, elem)
        $rootScope.$apply()

]