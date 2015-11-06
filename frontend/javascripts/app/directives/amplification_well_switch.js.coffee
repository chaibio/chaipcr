window.ChaiBioTech.ngApp.directive 'amplificationWellSwitch', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    templateUrl: 'app/views/directives/amplification-well-switch.html'
    link: ($scope, elem, attrs, ngModel) ->

      COLORS = [
        '#04A0D9'
        '#1578BE'
        '#2455A8'
        '#3B2F90'
        '#73258C'
        '#B01C8B'
        '#FA1284'
        '#FF004E'
        '#EA244E'
        '#FA3C00'
        '#EF632A'
        '#F5AF13'
        '#FBDE26'
        '#B6D333'
        '#67BC42'
        '#13A350'
      ]

      $scope.loop = [0..7]
      $scope.buttons = {}

      watchButtons = (val) ->
        ngModel.$setViewValue angular.copy val

      for i in [0..15] by 1
        $scope.buttons["well_#{i}"] =
          selected : true
          color: COLORS[i]

      $scope.$watch 'buttons', watchButtons, true

]