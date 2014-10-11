ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomContainer = Backbone.View.extend({

  className: "bottom-container",

  initialize: function() {
    this.pastePalette();
    this.pasteTestInProgress();
  },

  pastePalette: function() {
    this.palette = new ChaiBioTech.app.Views.palette({
      model: this.model
    });
  },

  pasteTestInProgress: function() {
    this.testInProgress = new ChaiBioTech.app.Views.testInProgress({
      model: this.model
    });
  },

  render: function() {
    $(this.el).append(this.palette.render().el);
    $(this.el).append(this.testInProgress.render().el);
    return this;
  }
});
