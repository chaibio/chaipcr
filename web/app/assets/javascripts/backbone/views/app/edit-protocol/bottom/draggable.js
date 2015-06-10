ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.draggable = Backbone.View.extend({

  onState: false,

  setRed: false,

  setBlue: false,

  template: JST["backbone/templates/app/capsule"],

  className: "capsule",

  events: {
    "click .plus": "plusClicked",
    "click .minus": "minusClicked",
    "click": "toggle"
  },

  initialize: function() {

    var that = this;

    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.onState = data.autoDelta;
      if(! data["systemGenerated"]) {
        that.onOffDrag(that.onState);
      }

    });

    this.options.editStepStageClass.on("stepSelected", function(data) {

      that.onState = data.parentStage.model.get("stage")["auto_delta"];

      that.onOffDrag(that.onState);
    });

    this.on("positive", function() {

      $(this.drag).css("left", "36px");
      this.changeColor(36, $(this.drag));
    });

    this.on("negative", function(){

      $(this.drag).css("left", "0px");
      this.changeColor(0, $(this.drag));
    });

  },

  plusClicked: function(evt) {

    evt.preventDefault();
    if(this.onState) {
      this.trigger("negative");
      this.options.parent.trigger("signChanged", -1);

    }
  },

  minusClicked: function(evt) {

    evt.preventDefault();
    if(this.onState) {
      this.trigger("positive");
      this.options.parent.trigger("signChanged", +1);
    }
  },

  toggle: function() {

    if(this.onState) {
      var pos = $(this.el).find(".ball-cover").position().left;
      if(pos < 18) {
        this.trigger("positive");
        this.options.parent.trigger("signChanged", 1);
      } else {
        this.trigger("negative");
        this.options.parent.trigger("signChanged", -1)
      }
    }
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

  onOffDrag: function(status) {

    var elem = $(this.el).find(".ball-cover");
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
