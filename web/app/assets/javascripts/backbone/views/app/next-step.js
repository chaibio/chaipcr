ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.nextStep = Backbone.View.extend({

  className: "next",

  template: JST["backbone/templates/app/previous-step"],

  events : {
    "click .next-img": "selectNext"
  },

  selectNext: function() {
    var selectStep = ChaiBioTech.app.selectedStep;
    if(selectStep.nextStep) {
      selectStep.nextStep.parentStage.selectStage();
      selectStep.nextStep.selectStep();
      ChaiBioTech.app.Views.mainCanvas.renderAll();
    } else if(selectStep.parentStage.nextStage) {
      var stage = selectStep.parentStage.nextStage;
      stage.selectStage();
      stage.childSteps[0].selectStep();
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
