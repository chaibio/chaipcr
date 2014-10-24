ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.deviceRunMiddleSection = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-middle-section"],

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
