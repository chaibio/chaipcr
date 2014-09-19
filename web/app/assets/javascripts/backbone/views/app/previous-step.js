ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.previousStep = Backbone.View.extend({

  className: "previous",

  template: JST["backbone/templates/app/previous-step"],

  events : {
    "click .next-img": "selectNext"
  },

  selectNext: function() {
    console.log(ChaiBioTech.app.selectedStep);
  },

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
