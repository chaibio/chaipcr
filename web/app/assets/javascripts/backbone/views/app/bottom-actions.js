ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomActions = Backbone.View.extend({

  className: "action-container",

  template: JST["backbone/templates/app/bottom-actions"],

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
