ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.generalInfo = Backbone.View.extend({

  autoDelta: false,

  gatherData: false,

  currentStep: null,

  template: JST["backbone/templates/app/bottom-general-info"],

  initialize: function() {

    var that  = this;

    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.currentStep = data;
      that.changeInfo(data);
    });

    _.bindAll(this, 'handleClcik');
  },

  events: {
    "click #gather-data-button": "showGatherDataPopUp",
    "click #during-step": "enableDuringStep",
    "click #after-step": "enableDuringRamp",
    "click .bottom-name-of-step-stage": "showStepNameEdit",
    "keydown .bottom-name-of-step-stage": "editStepNameEnter",
    "blur .bottom-name-of-step-stage": "saveAndHideStepName",
    "click .bottom-step-no-cycle": "editNoOfCycle",
    "keydown .bottom-step-no-cycle": "editNoOfCyclesEnter",
    "blur .bottom-step-no-cycle": "saveAndHideCycle",
    "click #delta-button": "autoDelta"
  },

  autoDelta: function() {

    var stageModel = this.currentStep.parentStage.model.get("stage");

    if(stageModel["stage_type"] == "cycling") {
      this.autoDelta = ! this.autoDelta;
      var data = {
        "autoDelta": this.autoDelta,
        "currentStep": this.currentStep,
        "systemGenerated": false,
      }
      this.options.editStepStageClass.trigger("delta_clicked", data);
      // here send data to server or trigger it back to canvas using
      ChaiBioTech.app.Views.mainCanvas.fire("deltaChanged", this.currentStep.parentStage);
      this.fixDeltaButton(data);
    } else {
      alert("Please select a Cycling Stage");
    }

  },

  showStepNameEdit: function() {

    this.editStepName.show();
    this.editStepName.focus();
  },

  editStepNameEnter: function(e) {

    if(e.keyCode === 13) {
      this.editStepName.blur();
    }
  },

  editNoOfCycle: function(e) {

    if(this.currentStep.parentStage.model.get("stage").stage_type === "cycling") {
      this.numOfCyclesEdit.show();
      this.numOfCyclesEdit.focus();
    }
  },

  editNoOfCyclesEnter: function(e) {

    if(e.keyCode === 13) {
      this.numOfCyclesEdit.blur();
    }
  },

  saveAndHideCycle: function() {

    var newCycle = this.numOfCyclesEdit.val();

    this.numOfCyclesEdit.hide();

    if(!isNaN(newCycle)) {
      this.currentStep.parentStage.model.saveCycle(newCycle);
      this.numOfCycles.html(newCycle);
      this.currentStep.parentStage.updatedNoOfCycle = newCycle;
      ChaiBioTech.app.Views.mainCanvas.fire("cycleChangedFromBottom", this.currentStep);
    } else {
      this.numOfCyclesEdit.val(this.numOfCycles.html());
      alert("Please input a number");
    }
  },

  saveAndHideStepName: function() {

    var newStepName = this.editStepName.val();

    this.editStepName.hide();

    if(newStepName) {
      this.currentStep.model.saveName(newStepName);
      this.nameOfStepStage.html(newStepName);
      this.currentStep.updatedStepName = newStepName;
      ChaiBioTech.app.Views.mainCanvas.fire("stepNameChangedFromBottom", this.currentStep);
    } else {
      this.editStepName.val(this.nameOfStepStage.html());
      alert("Please input some value");
    }
  },

  enableDuringStep: function() {

    if(ChaiBioTech.app.selectedStep) {
      ChaiBioTech.app.selectedStep.gatherDuringStep();
    }

    this.fixGatherDataButtonStatus(ChaiBioTech.app.selectedStep);
  },

  enableDuringRamp: function() {

    if(ChaiBioTech.app.selectedStep) {
      ChaiBioTech.app.selectedStep.gatherDuringRamp();
    }

    this.fixGatherDataButtonStatus(ChaiBioTech.app.selectedStep);
  },

  fixGatherDataButtonStatus: function(step) {
    // Looks after how gather data button is working as we change during step/ramp
    if(step.gatherDataDuringStep || step.gatherDataDuringRamp) {
      this.gatherDataButtonImage.show();
      this.gatherDataButton.css("background-color", "black");
      this.gatherDataButton.css("color", "white");
      this.gatherDataButtonText.html("GATHER DATA ON");
    } else {
      this.gatherDataButtonImage.hide();
      this.gatherDataButton.css("background-color", "white");
      this.gatherDataButton.css("color", "black");
      this.gatherDataButtonText.html("GATHER DATA OFF");
    }
  },

  showGatherDataPopUp: function(e) {

    e.preventDefault();
    e.stopPropagation();
    this.popUp.show();
    this.manageTikImage();
    $('body').on("click", this.handleClcik);
  },

  manageTikImage: function() {
    // Takes care of image on the gather data pop up
    if(ChaiBioTech.app.selectedStep.gatherDataDuringStep) {
      this.tikImageDuringStep.show();
    } else {
      this.tikImageDuringStep.hide();
    }

    if(ChaiBioTech.app.selectedStep.gatherDataDuringRamp) {
      this.tikImageDuringRamp.show();
    } else {
      this.tikImageDuringRamp.hide();
    }
  },

  handleClcik: function() {

    if(this.popUp.is(":visible")) {
      this.popUp.hide();
      // Now we turn this off, So that it wont bothr on any other click.
      $("body").off("click", this.handleClcik);
    }
  },

  changeInfo: function(step) {

    var temp = (step.ordealStatus < 10) ? "0" + step.ordealStatus : step.ordealStatus;

    this.StepNo.html(temp);
    temp = step.parentStage.parent.allStepViews.length;
    temp = (temp < 10) ? "0" + temp : temp;
    this.noOfStages.html("/" + temp);
    this.nameOfStepStage.html(step.stepName.text);
    this.editStepName.val(step.stepName.text);
    this.smallStageName.html(step.parentStage.stageName.text);

    if(step.parentStage.model.get("stage").stage_type === "cycling") {
      this.cycleConatainer.css("visibility", "visible");
    } else {
      this.cycleConatainer.css("visibility", "hidden");
    }

    this.numOfCycles.html(step.parentStage.updatedNoOfCycle || step.parentStage.model.get("stage").num_cycles);
    this.numOfCyclesEdit.val(step.parentStage.updatedNoOfCycle || step.parentStage.model.get("stage").num_cycles);
    this.manageTikImage();
    this.fixGatherDataButtonStatus(step);

    // Here we change the status of auto delta button ...!!
    //console.log(step.parentStage.model.get("stage"));
    var stageModel = step.parentStage.model.get("stage");
    this.autoDelta = stageModel["auto_delta"];


    var data = {
      "autoDelta": this.autoDelta,
      "currentStep": this.currentStep,
      "systemGenerated": true,
    }
    // This is a fake call, just reusing code for actual delta clicked .. !!
    this.options.editStepStageClass.trigger("delta_clicked", data);

    this.fixDeltaButton(data);

  },

  fixDeltaButton: function(data) {

    if(data["autoDelta"]) {
      this.deltaImage.show();
      this.deltaButton.css("background-color", "black");
      this.deltaButton.css("color", "white");
      this.deltaButtonText.html("AUTODELTA ON");
    } else {
      this.deltaImage.hide();
      this.deltaButton.css("background-color", "white");
      this.deltaButton.css("color", "black");
      this.deltaButtonText.html("AUTODELTA OFF");
    }
  },

  render: function() {

    $(this.el).html(this.template());
    this.StepNo = $(this.el).find(".bottom-step-no");
    this.noOfStages = $(this.el).find(".bottom-no-of-stages");
    this.nameOfStepStage = $(this.el).find(".bottom-name-of-step-span");
    this.smallStageName = $(this.el).find(".bottom-stage-name");
    this.numOfCycles = $(this.el).find(".bottom-step-no-cycle-span");
    this.numOfCyclesEdit = $(this.el).find(".bottom-step-no-cycle-edit");
    this.popUp = $(this.el).find('.lol-pop');
    this.tikImageDuringStep = $(this.el).find('.tik-image-during-step');
    this.tikImageDuringRamp = $(this.el).find('.tik-image-during-ramp');

    this.deltaButton = $(this.el).find("#delta-button");
    this.deltaImage = $(this.el).find(".delta-button-image");
    this.deltaButtonText = $(this.el).find(".delta-button-text");

    this.gatherDataButton = $(this.el).find('#gather-data-button');
    this.gatherDataButtonImage = $(this.el).find('.gather-data-button-image');
    this.gatherDataButtonText = $(this.el).find('.gather-data-button-text');

    this.editStepName = $(this.el).find('.edit-step-name');
    this.cycleConatainer = $(this.el).find(".bottom-step-no-cycle-container");
    return this;
  }
});
