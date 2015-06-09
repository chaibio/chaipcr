ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.errorModel = Backbone.View.extend({

  className: "error-model-container",

  template: JST["backbone/templates/app/notifications/error-model"],

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
