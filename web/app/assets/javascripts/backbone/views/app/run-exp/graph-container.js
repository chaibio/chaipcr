ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.graphContainer = Backbone.View.extend({

  className: "graph-container",

  template: JST["backbone/templates/app/run-exp/graph"],

  initialize: function() {
    console.log("bingo");
  },

  render: function() {

    $(this.el).html(this.template());
    return this;
  }


});
