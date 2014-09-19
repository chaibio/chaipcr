ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomHoldDuration = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "HOLD DURATION",
      data: "0:30"
    }
    $(this.el).html(this.template(data));
    return this;
  }
});
