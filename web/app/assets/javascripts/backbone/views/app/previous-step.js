ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.previousStep = Backbone.View.extend({

  className: "previous",

  template: JST["backbone/templates/app/previous-step"],

  events : {
    "click .next-img": "selectPrevious"
  },

  selectPrevious: function() {
    var selectStep = ChaiBioTech.app.selectedStep;
    if(selectStep.previousStep) {
      selectStep.previousStep.parentStage.selectStage();
      selectStep.previousStep.selectStep();
      ChaiBioTech.app.Views.mainCanvas.renderAll();
    } else if(selectStep.parentStage.previousStage) {
      var stage = selectStep.parentStage.previousStage;
      stage.selectStage();
      stage.childSteps[stage.childSteps.length - 1].selectStep();
      ChaiBioTech.app.Views.mainCanvas.renderAll();
    }
  },

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
