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
      selectStep.previousStep.circle.manageClick();
    } else if(selectStep.parentStage.previousStage) {
      var stage = selectStep.parentStage.previousStage;

      stage.childSteps[stage.childSteps.length - 1].circle.manageClick();
    }
    this.options.editStepStageClass.trigger("stepSelected", ChaiBioTech.app.selectedStep);
  },

  initialize: function() {

  },

  render: function() {

    $(this.el).html(this.template());
    
    return this;
  }
});
