ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.testInProgress = Backbone.View.extend({

  className: "test-in-progress-container",

  initialize: function() {
    // Okay bring the already done experiment in progress
    // Remove this , because it has different look and feel
    this.exp = new ChaiBioTech.app.Views.experimentInProgress();
  },

  render: function() {
    $(this.el).append(this.exp.render().el);
    return this;
  }
});
