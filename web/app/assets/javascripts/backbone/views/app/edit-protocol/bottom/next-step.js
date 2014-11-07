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
      selectStep.nextStep.circle.manageClick();
    } else if(selectStep.parentStage.nextStage) {
      var stage = selectStep.parentStage.nextStage;

      stage.childSteps[0].circle.manageClick();
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
