ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.generalInfo = Backbone.View.extend({

  autoDelta: false,

  gatherData: false,
  
  template: JST["backbone/templates/app/bottom-general-info"],

  initialize: function() {
    //console.log("Cool");
  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }
});
