ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceRunButtons = Backbone.View.extend({

  className: "device-run-buttons-container",

  template: JST["backbone/templates/800x480/run/device-run-button"],

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }

});
