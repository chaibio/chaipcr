ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomActions = Backbone.View.extend({

  className: "action-container",

  template: JST["backbone/templates/app/bottom-actions"],

  events: {
    "click #add-step": "addStep",
    "click #delete-step": "deleteStep",
    "click #add-stage": "addStage",
    "click #add-holding": "addHoldingStage",
    "click #add-cycling": "addCyclingStage",
    "click #add-melt-curve": "addMeltCurveStage"
  },

  addStage: function(e) {
    e.preventDefault();
    e.stopPropagation();
    this.popUp.show();
    $("body").on("click",this.handleClickOn);
  },

  commonAddStage: function(type) {
    if(ChaiBioTech.app.selectedStage) {
      var protocolId = null;
      this.fixCurrentStepStage();
      protocolId = this.currentSelectedStage.parent.model.get("experiment").protocol.id;
      this.selectedStageModel.addStage(type, protocolId, this.currentSelectedStage);
    } else {
      alert("Please select a stage/step");
    }
  },

  handleClickOn: function() {
    if(this.popUp.is(":visible")) {
      this.popUp.hide();
      // Now we turn this off, So that it wont bothr on any other click.
      $("body").off("click", this.handleClcikOn);
    }
  },

  addHoldingStage: function() {
    this.commonAddStage("holding");
  },

  addCyclingStage: function() {
    this.commonAddStage("cycling");
  },

  addMeltCurveStage: function() {
    this.commonAddStage("melt_curve");
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
    // Bind it to 'this' object. handleClcikOn has html scope because its called from jquery event.
    _.bindAll(this, "handleClickOn");
  },

  render: function() {
    $(this.el).html(this.template());
    this.popUp = $(this.el).find(".lol-pop");
    return this;
  }
});
