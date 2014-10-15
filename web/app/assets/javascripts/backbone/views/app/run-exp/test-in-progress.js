ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.testInProgress = Backbone.View.extend({

  className: "test-in-progress-container",

  initialize: function() {
    this.exp = new ChaiBioTech.app.Views.experimentInProgressBar();
  },

  render: function() {
    $(this.el).append(this.exp.render().el);
    return this;
  }
});
