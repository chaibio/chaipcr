ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomActions = Backbone.View.extend({

  className: "action-container",

  template: JST["backbone/templates/app/bottom-actions"],

  events: {
    "click #add-step": "addStep",
    "click #delete-step": "deleteStep"
  },

  addStep: function() {
    if(ChaiBioTech.app.selectedStep) { // Works only if a step has been selected already
      var stageId =  null;
      this.fixCurrentStepStage();
      stageId = this.selectedStageModel.get("stage").id;
      this.selectedStepModel.addStep(stageId, this.currentSelectedStep);
    } else {
      alert("Please select a step.");
    }
  },

  deleteStep: function() {
    if(ChaiBioTech.app.selectedStep) {
      var stepId =  null;
      this.fixCurrentStepStage();
      stepId = this.selectedStepModel.get("step").id;
      this.selectedStepModel.deleteStep(stepId, this.currentSelectedStep);
    } else {
      alert("Please select a step.")
    }
  },

  fixCurrentStepStage: function() {
    this.currentSelectedStep = ChaiBioTech.app.selectedStep;// This is a fabric object
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
