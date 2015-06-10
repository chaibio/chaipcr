ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.errorModel = Backbone.View.extend({

  className: "error-model-container",

  template: JST["backbone/templates/app/notifications/error-model"],

  events: {
    "click .error-model-close": "close",
    "click .error-model-okay-button": "okay",
    "click .error-model-cancel-button": "cancel"
  },

  initialize: function() {

  },

  okay: function() {
    this.remove();
    this.options.parent.trigger("okay");
  },

  cancel: function() {
    this.remove();
    this.options.parent.trigger("cancel");
  },

  close: function() {
    this.remove();
  },

  render: function() {

    $(this.el).html(this.template(this.options.message));
    return this;
  }
});
