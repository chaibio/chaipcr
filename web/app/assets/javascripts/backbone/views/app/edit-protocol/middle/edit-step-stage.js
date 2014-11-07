ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.editStageStep = Backbone.View.extend({

  className: "edit-stage-step-container",

  template: JST["backbone/templates/app/edit-stage-step"],

  initialize: function() {

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

    return this;
  },

  pasteCanvasContainer: function() {

    this.canvasContainer = new ChaiBioTech.app.Views.canvasContainer();

    return this;
  },

  pastePrevious: function() {

    this.previousStep = new ChaiBioTech.app.Views.previousStep({
      editStepStageClass: this
    });

    return this;
  },

  pasteMiddleContainer: function() {

    this.middleContainer = new ChaiBioTech.app.Views.bottomMiddleContainer({
      editStepStageClass: this
    });

    return this;
  },

  pasteNext: function() {

    this.nextStep = new ChaiBioTech.app.Views.nextStep({
      editStepStageClass: this
    });

    return this;
  },

  render: function() {

    $(this.el).html(this.template());

    var topHalf = $(this.el).find(".top-half");
    var bottomHalf = $(this.el).find(".bottom-half");

    topHalf.append(this.nameOnTop.render().el);
    topHalf.append(this.canvasContainer.render().el);
    bottomHalf.append(this.previousStep.render().el);
    bottomHalf.append(this.middleContainer.render().el);
    bottomHalf.append(this.nextStep.render().el);

    return this;
  }
});
