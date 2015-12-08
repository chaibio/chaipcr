window.ChaiBioTech.ngApp.factory('dots', [

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
