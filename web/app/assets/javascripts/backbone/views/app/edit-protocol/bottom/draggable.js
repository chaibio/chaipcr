ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.draggable = Backbone.View.extend({

  on: false,

  setRed: false,

  setBlue: false,

  initialize: function() {

    var that = this;

    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.on = data.autoDelta;
      that.onOffDrag(that.on, that.options.element);
    });
    // Here we are writing the behaviour of scroll
    this.options.element.draggable({
      containment: "parent",
      axis: "x",
      // If the user has not dragged the switch to the end..!
      // We auto adjust the position of the switch
      stop: function() {
        var pos = $(this).position().left;
        if(pos < 18) {
          $(this).css("left", "0px");
        } else {
          $(this).css("left", "36px");
        }
      },

      drag: function() {
        var pos = $(this).position().left;
        that.changeColor(pos, this);
      }
    });

    return this.options.element;
  },

  changeColor: function(pos, elem) {

    if(pos < 18 && ! that.setBlue && that.on) {
      $(elem).parent().css("background-color", "#00aeef");
      $(elem).find(".center-circle").css("background-color", "#00aeef");
      $(elem).parent().find(".sansa").css("color", "#ffffff");
      this.setBlue = true;
      this.setRed = false;
    } else if(pos > 18 && ! that.setRed && that.on){
      $(elem).parent().css("background-color", "#ee3118");
      $(elem).find(".center-circle").css("background-color", "#ee3118");
      $(elem).parent().find(".sansa").css("color", "#ffffff");
      this.setBlue = false;
      this.setRed = true;
    }
  },

  onOffDrag: function(status, elem) {

    if(status == false) {
      $(elem).parent().css("background-color", "#cdcdcd");
      $(elem).find(".center-circle").css("background-color", "#cdcdcd");
      $(elem).parent().find(".sansa").css("color", "grey");
    } else {

      if(this.setBlue) {
        $(elem).parent().css("background-color", "#00aeef");
        $(elem).find(".center-circle").css("background-color", "#00aeef");
        $(elem).parent().find(".sansa").css("color", "#ffffff");
      } else if(this.setRed){
        $(elem).parent().css("background-color", "#ee3118");
        $(elem).find(".center-circle").css("background-color", "#ee3118");
        $(elem).parent().find(".sansa").css("color", "#ffffff");
      } else {
        $(elem).parent().css("background-color", "#00aeef");
        $(elem).find(".center-circle").css("background-color", "#00aeef");
        $(elem).parent().find(".sansa").css("color", "#ffffff");
        this.setBlue = true;
      }

    }
  }
});
