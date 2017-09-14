###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp.directive 'amplificationWellSwitch', [
  'AmplificationChartHelper',
  '$timeout',
  '$state',
  (AmplificationChartHelper, $timeout) ->
    restrict: 'EA'
    require: 'ngModel'
    scope:
      colorBy: '='
      buttonLabelsNum: '=?' #numbe of labels in button
      labelUnit: '=?'
      chartType: '@'

    ###templateUrl: 'app/views/directives/amplification-well-switch.html'###
    link: ($scope, elem, attrs, ngModel) ->

      buttons = {}
      for i in [0..15] by 1
        buttons["well_#{i}"] = {}

      ngModel.$setViewValue(buttons)

      wheelswitch = new window.ChaiBioTech.WellSwitch elem[0], null

]
