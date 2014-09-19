ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTime = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "TIME.",
      data: "0:05"
    }
    $(this.el).html(this.template(data));
    return this;
  }
});
