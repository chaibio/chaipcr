ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomMiddleContainer = Backbone.View.extend({

  className: "middle-ground",

  template: JST["backbone/templates/app/middle-container"],

  initialize: function() {
    this.temperatureSection = new ChaiBioTech.app.Views.bottomTemperature();
    this.rampSpeedSection = new ChaiBioTech.app.Views.bottomRampSpeed();
    this.holdDurationSection = new ChaiBioTech.app.Views.bottomHoldDuration();
    this.startOnCycleSection = new ChaiBioTech.app.Views.bottomStartOnCycle();
    this.tempSection = new ChaiBioTech.app.Views.bottomTemp();
    this.timeSection = new ChaiBioTech.app.Views.bottomTime();
    this.actions = new ChaiBioTech.app.Views.bottomActions();
  },

  render: function() {
    $(this.el).html(this.template());
    
    var firstBox = $(this.el).find(".temperature-change"),
    secondBox = $(this.el).find(".auto-delta"),
    thirdBox = $(this.el).find(".edit-stage-step");

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
