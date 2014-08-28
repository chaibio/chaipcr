ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.nameOnTop = Backbone.View.extend({

  className: "name-on-top",

  template: JST["backbone/templates/app/name-on-top"],

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
})
