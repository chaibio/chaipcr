ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomStartOnCycle = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "START ON CYCLE:",
      data: "1"
    }
    $(this.el).html(this.template(data));
    //Disabling for now;
    $(this.el).addClass("disabled");
    return this;
  }
});
