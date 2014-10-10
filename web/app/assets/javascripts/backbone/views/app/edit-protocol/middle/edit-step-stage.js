ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.editStageStep = Backbone.View.extend({

  className: "edit-stage-step-container",

  template: JST["backbone/templates/app/edit-stage-step"],

  initialize: function() {
    // This is an event originated from canvas. Now Listen to this class to get all the update
    // We will b triggering all the events to this class from fabric.
    /*this.on("stepSelected", function(data) {
      console.log("Yes", data);
    });*/

    this.pasteName();
    this.pasteCanvasContainer();
    this.pastePrevious();
    this.pasteMiddleContainer();
    this.pasteNext();
  },

  pasteName: function() {
    this.nameOnTop = new ChaiBioTech.app.Views.nameOnTop({
      model: this.model
    });
  },

  pasteCanvasContainer: function() {
    this.canvasContainer = new ChaiBioTech.app.Views.canvasContainer();
  },

  pastePrevious: function() {
    this.previousStep = new ChaiBioTech.app.Views.previousStep({
      editStepStageClass: this
    });
  },

  pasteMiddleContainer: function() {
    this.middleContainer = new ChaiBioTech.app.Views.bottomMiddleContainer({
      editStepStageClass: this
    });
  },

  pasteNext: function() {
    this.nextStep = new ChaiBioTech.app.Views.nextStep({
      editStepStageClass: this
    });
  },

  render: function() {
    $(this.el).html(this.template());
    var topHalf = $(this.el).find(".top-half"),
    bottomHalf = $(this.el).find(".bottom-half");
    topHalf.append(this.nameOnTop.render().el);
    topHalf.append(this.canvasContainer.render().el);
    bottomHalf.append(this.previousStep.render().el);
    bottomHalf.append(this.middleContainer.render().el);
    bottomHalf.append(this.nextStep.render().el);
    return this;
  }
});
