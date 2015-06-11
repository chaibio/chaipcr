ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayLongTail = Backbone.View.extend({

  className:"long-tail-container",

  template: JST["backbone/templates/app/menu-overlay/long-tail"],

  initialize: function() {

  },

  render: function() {

    $(this.el).html(this.template());
    return this;
  }
});
