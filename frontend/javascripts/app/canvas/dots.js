window.ChaiBioTech.ngApp.factory('dots', [

  function() {

    this.smallDotArray = [];
    
    this.stageDots = function() {

    };

    this.getCordinates = function() {

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

    this.stepDots = function() {

      this.smallDotArray = [];

      for(var dot in this.dotCordiantes) {
        var cord = this.dotCordiantes[dot];
        this.smallDotArray.push(new fabric.Circle({
          radius: 2, fill: 'white', left: cord[0], top: cord[1], selectable: false,
          name: "stepDot", originX: "center", originY: "center"
        }));
      }

      return this.smallDotArray;
    };

    this.dotCordiantes = this.getCordinates();

    return this;
  }
]);
