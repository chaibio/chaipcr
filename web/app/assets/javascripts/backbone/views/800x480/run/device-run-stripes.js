ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.deviceRunStripes = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-stripes"],

  className: "device-run-stripe-container",

  initialize: function() {
    console.log("wooo");
  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
