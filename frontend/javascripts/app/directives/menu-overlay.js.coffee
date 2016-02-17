window.ChaiBioTech.ngApp.directive 'menuOverlay', [
  '$rootScope'
  '$templateCache'
  '$compile'
  ($rootScope, $templateCache, $compile) ->

    restrict: 'EA'
    transclude: true
    replace: true
    scope:
      sidemenuTemplate: '@'
    templateUrl: 'app/views/directives/menu-overlay.html'
    link: ($scope, elem) ->

      $scope.sideMenuOpen = false
      $scope.sideMenuOptionsOpen = false
      subMenuTemplate = "app/views/experiment/experiment-properties-suboption.html"

      sidemenu = $templateCache.get $scope.sidemenuTemplate
      compiled = $compile(sidemenu)($scope.$parent)
      sidemenuContainer = elem.find('#sidemenu-content')
      sidemenuContainer.html compiled

      $rootScope.$on 'sidemenu:toggle', ->
        if $scope.sideMenuOptionsOpen
          template = $templateCache.get subMenuTemplate
          compiled = $compile(template)($scope.$parent)
          arrow = elem.find('.arrow-right')
          $rootScope.$broadcast('submenu:toggle', compiled, elem)
          $rootScope.$apply()
        else
          sidemenuContainer.css minHeight: elem.find('.page-wrapper').height()

          $scope.sideMenuOpen = !$scope.sideMenuOpen


        # also close the submenu
        if !$scope.sideMenuOpen
          $scope.sideMenuOptionsOpen = false
          elem.find('.menu-overlay-menu-item').removeClass 'active'


      $rootScope.$on 'submenu:toggle', (e, html, subOption) ->
        $scope.sideMenuOptionsOpen = !$scope.sideMenuOptionsOpen
        elem.find('#submenu').html html

        if $scope.sideMenuOptionsOpen
          subOption.addClass('active')
          angular.element(".close-side-menu").addClass("sub-menu-open")
        else
          subOption.removeClass('active')
          angular.element(".close-side-menu").removeClass("sub-menu-open")



]
