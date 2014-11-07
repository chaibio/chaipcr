ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomMiddleContainer = Backbone.View.extend({

  className: "middle-ground",

  template: JST["backbone/templates/app/middle-container"],

  initialize: function() {
    // Keeping this object so that other classes can listen to it
    // for changes in fabric canvas
    var parentViewClass = this.options.editStepStageClass;

    this.generalInfo = new ChaiBioTech.app.Views.generalInfo({
      editStepStageClass: parentViewClass
    });

    this.temperatureSection = new ChaiBioTech.app.Views.bottomTemperature({
      editStepStageClass: parentViewClass
    });

    this.rampSpeedSection = new ChaiBioTech.app.Views.bottomRampSpeed({
      editStepStageClass: parentViewClass
    });

    this.holdDurationSection = new ChaiBioTech.app.Views.bottomHoldDuration({
      editStepStageClass: parentViewClass
    });

    this.startOnCycleSection = new ChaiBioTech.app.Views.bottomStartOnCycle({
      editStepStageClass: parentViewClass
    });

    this.tempSection = new ChaiBioTech.app.Views.bottomTemp({
      editStepStageClass: parentViewClass
    });

    this.timeSection = new ChaiBioTech.app.Views.bottomTime({
      editStepStageClass: parentViewClass
    });

    this.actions = new ChaiBioTech.app.Views.bottomActions();
  },

  render: function() {

    $(this.el).html(this.template());

    var firstBox = $(this.el).find(".temperature-change");
    var secondBox = $(this.el).find(".auto-delta");
    var thirdBox = $(this.el).find(".edit-stage-step");
    var firstRow = $(this.el).find(".first-data-row");

    firstRow.append(this.generalInfo.render().el);
    firstBox.append(this.temperatureSection.render().el);
    firstBox.append(this.rampSpeedSection.render().el);
    firstBox.append(this.holdDurationSection.render().el);
    secondBox.append(this.startOnCycleSection.render().el);
    secondBox.append(this.tempSection.render().el);
    secondBox.append(this.timeSection.render().el);
    thirdBox.append(this.actions.render().el);
    
    return this;
  }
});
