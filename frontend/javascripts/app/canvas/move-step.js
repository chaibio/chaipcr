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

        var stageText = new fabric.Text(
          "MOVING STAGE 2", {
            fill: 'black',  fontSize: 10, selectable: false, originX: 'left', originY: 'top',
            top: 12, left: 10, fontFamily: "Open Sans", fontWeight: "bold"
          }
        );

        var stepText = new fabric.Text(
          "STEP: 2", {
            fill: 'black',  fontSize: 10, selectable: false, originX: 'left', originY: 'top',
            top: 25, left: 10, fontFamily: "Open Sans", fontWeight: "bold"
          }
        );

        var verticalLine = new fabric.Line([0, 0, 0, 263],{
          left: 66,
          top: -2,
          stroke: 'black',
          strokeWidth: 2
        });

        var rect = new fabric.Rect({
          fill: 'white', width: 120, left: 5, height: 40, selectable: false, name: "step", me: this, rx: 3,
        });

        this.indicator = new fabric.Group([
          //verticalLine,
          rect,
          //smallCircle,
          stageText,
          stepText,
        ],
          {
            originX: "left",
            originY: "top",
            width: 122,
            height:40,
            left: 33,
            top: 326,
            selectable: false,
            visible: false,
            name: "dragStepGroup"
          }
        );

      this.indicator.changeText = function(stageId, stepId) {

        var stageText = this.item(1);
        stageText.setText("MOVING STAGE " + (stageId + 1));

        var stepText = this.item(2);
        stepText.setText("STEP: " + (stepId + 1));

      };
        return this.indicator;
      },

    };
  }
]
);
