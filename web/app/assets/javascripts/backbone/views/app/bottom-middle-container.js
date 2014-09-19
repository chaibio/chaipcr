ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomMiddleContainer = Backbone.View.extend({

  className: "middle-ground",

  template: JST["backbone/templates/app/middle-container"],

  initialize: function() {
    this.temperatureSection = new ChaiBioTech.app.Views.bottomTemperature();
    this.rampSpeedSection = new ChaiBioTech.app.Views.bottomRampSpeed();
    this.holdDurationSection = new ChaiBioTech.app.Views.bottomHoldDuration();
  },

  render: function() {
    $(this.el).html(this.template());
    var firstBox = $(this.el).find(".temperature-change");
    firstBox.append(this.temperatureSection.render().el);
    firstBox.append(this.rampSpeedSection.render().el);
    firstBox.append(this.holdDurationSection.render().el);
    return this;
  }
});
