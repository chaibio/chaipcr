ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.experimentInProgressBar = Backbone.View.extend({

  className: "test-in-progress-bar-container",

  template: JST["backbone/templates/app/run-exp/experiment-in-progress-bar"],

  initialize: function() {

  },

  render: function() {
    $(this.el).append(this.template());
    return this;
  }
});
