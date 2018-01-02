/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

angular.module("canvasApp").factory('dots', [

  function() {

    this.getStageCordinates = function() {

      return  {
        "dot1": [1, 1], "dot2": [12, 1], "dot3": [6.5, 6], "dot4": [1, 10], "dot5": [12, 10],
      };

    };

    this.stepStageMoveDots = function() {

      var circleArray = [];
      var dotCordiantes = {
        "left": [1, 1], "right": [11, 1], "middle": [6, 6]
      };

      for(var i = 1; i < 30; i++) {
        dotCordiantes["left" + i] = [1, (11 * i) + 1];
        dotCordiantes["middle" + i] = [6, (11 * i) + 6];
        dotCordiantes["right" + i] = [11, (11 * i) + 1];
      }
      
      delete dotCordiantes["middle" + (i - 1)];

      for(var dot in dotCordiantes) {
        var cord = dotCordiantes[dot];
        circleArray.push(new fabric.Circle({
          radius: 2, fill: 'black', left: cord[0], top: cord[1], selectable: false,
          name: "stageDot", originX: "center", originY: "center"
        }));
      }

      return circleArray;
    };

    this.getStepCordinates = function() {

      var dotCordiantes = {
        "topDot0": [1, 1], "bottomDot0": [1, 10], "middleDot0": [6.5, 6],
      };

      for(var i = 1; i < 9; i++) {
        dotCordiantes["topDot" + i] = [(11 * i) + 1, 1];
        dotCordiantes["middleDot" + i] = [(11 * i) + 6.5, 6];
        dotCordiantes["bottomDot" + i] = [(11 * i) + 1, 10];
      }

      delete dotCordiantes["middleDot" + (i - 1)];
      return dotCordiantes;
    };

    this.prepareArray = function(cordinates) {

      var circleArray = [];

      for(var dot in cordinates) {
        var cord = cordinates[dot];
        circleArray.push(new fabric.Circle({
          radius: 2, fill: 'white', left: cord[0], top: cord[1], selectable: false,
          name: "stageDot", originX: "center", originY: "center"
        }));
      }
      return circleArray;
    };

    this.stepDots = function() {

      return this.prepareArray(this.stepDotCordiantes);
    };

    this.stageDots = function() {

      return this.prepareArray(this.stageDotCordinates);
    };

    this.stepDotCordiantes = this.getStepCordinates();
    this.stageDotCordinates = this.getStageCordinates();

    return this;
  }
]);
