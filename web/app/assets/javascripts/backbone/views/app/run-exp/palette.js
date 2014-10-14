ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.palette = Backbone.View.extend({

  className: "palette-container",

  // This has to be expanded further ...! Now its just an Image.
  template: JST["backbone/templates/app/run-exp/palette"],

  initialize: function() {

  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
