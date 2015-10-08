window.ChaiBioTech.ngApp.factory('moveStepRect', [

  function() {

    return {

      getMoveStepRect: function(me) {

        var smallCircle = new fabric.Circle({
          radius: 4,
          fill: 'black',
          selectable: false,
          left: 63,
          top: 259,
          //top: -2
        });

        var verticalLine = new fabric.Line([0, 0, 0, 263],{
          left: 66,
          top: -2,
          stroke: 'black',
          strokeWidth: 2
        });

        var rect = new fabric.Rect({
          fill: 'white', width: 120, left: 5, height: 40, selectable: false, name: "step", me: this, top: 264, rx: 3
        });

        this.indicator = new fabric.Group([
          //verticalLine,
          rect,
          //smallCircle,
        ],
          {
            originX: "left",
            originY: "top",
            width: 122,
            left: 33,
            top: 326,
            selectable: false,
            visible: false
          }
        );

        return this.indicator;
      },

    };
  }
]
);
