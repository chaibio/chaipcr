ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.draggable = Backbone.View.extend({

  onState: false,

  setRed: false,

  setBlue: false,

  initialize: function() {

    var that = this;

    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.onState = data.autoDelta;
      that.onOffDrag(that.onState, that.options.element);
    });

    // Here we are writing the behaviour of scroll
    this.drag = this.options.element.draggable({
      containment: "parent",
      axis: "x",
      // If the user has not dragged the switch to the end..!
      // We auto adjust the position of the switch
      create: function() {
        //create a reference to dragable
        that.dragDude = this;
      },

      stop: function() {
        alert("coool")
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

    this.on("positive", function() {
      $(this.dragDude).css("left", "36px");
      this.changeColor(36, this.dragDude);
    });

    this.on("negative", function(){
      $(that.dragDude).css("left", "0px");
      this.changeColor(0, this.dragDude)
    });
  },

  changeColor: function(pos, elem) {

    if(pos < 18 && ! this.setBlue && this.onState) {
      $(elem).parent().css("background-color", "#00aeef");
      $(elem).find(".center-circle").css("background-color", "#00aeef");
      $(elem).parent().find(".sansa").css("color", "#ffffff");
      this.setBlue = true;
      this.setRed = false;
    } else if(pos > 18 && ! this.setRed && this.onState){
      $(elem).parent().css("background-color", "#ee3118");
      $(elem).find(".center-circle").css("background-color", "#ee3118");
      $(elem).parent().find(".sansa").css("color", "#ffffff");
      this.setBlue = false;
      this.setRed = true;
    }
  },

  onOffDrag: function(status, elem) {

    if(status == false) {
      $(this.drag).draggable("disable");
      $(elem).parent().css("background-color", "#cdcdcd");
      $(elem).find(".center-circle").css("background-color", "#cdcdcd");
      $(elem).parent().find(".sansa").css("color", "grey");
    } else {

      $(this.drag).draggable("enable");
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
