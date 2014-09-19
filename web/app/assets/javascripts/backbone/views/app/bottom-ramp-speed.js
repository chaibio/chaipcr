ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomRampSpeed = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "RAMP SPEED",
      data: "MAX"
    }
    $(this.el).html(this.template(data));
    return this;
  }
});
