ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.generalInfo = Backbone.View.extend({

  autoDelta: false,

  gatherData: false,

  template: JST["backbone/templates/app/bottom-general-info"],

  initialize: function() {
    var that  = this;
    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.changeInfo(data)
    });
  },

  changeInfo: function(step) {
    var temp = (step.ordealStatus < 10) ? "0" + step.ordealStatus : step.ordealStatus;
    this.StepNo.html(temp);
    temp = step.parentStage.parent.allStepViews.length;
    temp = (temp < 10)? "0" + temp : temp;
    this.noOfStages.html("/" + temp);
    this.nameOfStepStage.html(step.stepName.text + "/"+ step.parentStage.stageName.text);
    this.smallStageName.html(step.parentStage.stageName.text);
    this.numOfCycles.html(step.parentStage.model.get("stage").num_cycles)
  },

  render: function() {
    $(this.el).html(this.template());
    this.StepNo = $(this.el).find(".bottom-step-no");
    this.noOfStages = $(this.el).find(".bottom-no-of-stages");
    this.nameOfStepStage = $(this.el).find(".bottom-name-of-step-stage");
    this.smallStageName = $(this.el).find(".bottom-stage-name");
    this.numOfCycles = $(this.el).find(".bottom-step-no-cycle");
    return this;
  }
});
