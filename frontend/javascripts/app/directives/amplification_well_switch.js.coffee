window.ChaiBioTech.ngApp.directive 'amplificationWellSwitch', [
  ->
    restrict: 'EA'
    require: 'ngModel'
    templateUrl: 'app/views/directives/amplification-well-switch.html'
    link: ($scope, elem, attrs, ngModel) ->

      COLORS = [
        '#FFE980'
        '#FFD380'
        '#FFAD80'
        '#FF6666'
        '#FF71BA'
        '#C890F4'
        '#3879FF'
        '#75E0FF'
        '#FFD200'
        '#FFA800'
        '#FF5A00'
        '#E50000'
        '#F0007C'
        '#8F1CE8'
        '#003CB7'
        '#00BEF5'
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