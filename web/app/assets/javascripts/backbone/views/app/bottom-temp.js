ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemp = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "TEMP.",
      data: "2.0º"
    }
    $(this.el).html(this.template(data));
    return this;
  }
});
