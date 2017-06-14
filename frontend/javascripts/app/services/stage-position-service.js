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

window.ChaiBioTech.ngApp.service('StagePositionService', [
  function() {
      var allStages = null;
        return {
            init: function(stages) {
                allStages = stages; // Setting the reference from canvas.js, just after all stages are created.
            },
            getPositionObject: function(stages) {
                
                if(!allStages) {
                    return null;
                }
                
                this.allPositions = [];
                allStages.forEach(function(stage, index) {
                    this.allPositions[index] = [
                            stage.left, 
                            (stage.left + (stage.myWidth) / 2),
                            stage.left + stage.myWidth
                        ];
                }, this);
                return this.allPositions;
            },

            getAllVoidSpaces: function() {
                if(!allStages) {
                    return null;
                }

                this.allVoidSpaces = [];
                
                allStages.forEach(function(stage, index) {
                    if(index === 0) {
                        this.allVoidSpaces[0] = [
                            33,
                            stage.left
                        ];
                    }  else {
                        this.allVoidSpaces[index] = [
                            stage.previousStage.left + stage.previousStage.myWidth,
                            stage.left
                        ];
                    }
                }, this);
                console.log(this.allVoidSpaces);
            }
        };
    }
]);
