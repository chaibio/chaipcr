ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomActions = Backbone.View.extend({

  className: "action-container",

  template: JST["backbone/templates/app/bottom-actions"],

  events: {
    "click #add-step": "addStep"
  },

  addStep: function() {
    var stageId =  null;
    this.fixCurrentStepStage();
    stageId = this.selectedStageModel.get("stage").id;
    this.selectedStepModel.addStep(stageId, this.currentSelectedStep);
  },

  fixCurrentStepStage: function() {
    this.currentSelectedStep = ChaiBioTech.app.selectedStep;
    this.selectedStepModel = this.currentSelectedStep.model;
    this.currentSelectedStage = ChaiBioTech.app.selectedStage;
    this.selectedStageModel = this.currentSelectedStage.model;
  },

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
