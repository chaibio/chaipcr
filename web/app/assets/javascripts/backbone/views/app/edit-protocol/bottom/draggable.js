ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.draggable = Backbone.View.extend({

  onState: false,

  setRed: false,

  setBlue: false,

  template: JST["backbone/templates/app/capsule"],

  className: "capsule",

  events: {
    "click .plus": "plusClicked"
  },

  initialize: function() {
    //this.render();
    var that = this;
    // Here we are writing the behaviour of scroll
    /*this.drag = this.options.element.draggable({
      containment: "parent",
      axis: "x",
      // If the user has not dragged the switch to the end..!
      // We auto adjust the position of the switch
      create: function() {
        //create a reference to dragable
        that.dragDude = this;
      },

      stop: function() {

        var pos = $(this).position().left;
        if(pos < 18) {
          $(this).css("left", "0px");
          that.options.parent.trigger("signChanged", -1);
        } else {
          $(this).css("left", "36px");
          that.options.parent.trigger("signChanged", 1)
        }
      },

      drag: function() {
        var pos = $(this).position().left;
        that.changeColor(pos, this);
      }
    });*/

    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.onState = data.autoDelta;
      that.onOffDrag(that.onState, $(this).find(".ball-cover"));
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

  plusClicked: function() {
    console.log("plus")
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

      try {
        $(this.drag).draggable("disable");
      } catch(err) {
        console.log("Happens for the init")
      }

      $(elem).parent().css("background-color", "#cdcdcd");
      $(elem).find(".center-circle").css("background-color", "#cdcdcd");
      $(elem).parent().find(".sansa").css("color", "grey");
    } else {

      try {
        $(this.drag).draggable("enable");
      } catch(err) {
        console.log("Happens for the init")
      }

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
  },

  render: function() {

    $(this.el).html(this.template());

    var that = this;
    // Here we are writing the behaviour of scroll
    this.drag = $(this.el).find(".ball-cover").draggable({
      containment: "parent",
      axis: "x",
      // If the user has not dragged the switch to the end..!
      // We auto adjust the position of the switch
      create: function() {
        //create a reference to dragable
        that.dragDude = this;
      },

      stop: function() {
        
        var pos = $(this).position().left;
        if(pos < 18) {
          $(this).css("left", "0px");
          that.options.parent.trigger("signChanged", -1);
        } else {
          $(this).css("left", "36px");
          that.options.parent.trigger("signChanged", 1)
        }
      },

      drag: function() {
        var pos = $(this).position().left;
        that.changeColor(pos, this);
      }
    });


    return this;
  }
});
