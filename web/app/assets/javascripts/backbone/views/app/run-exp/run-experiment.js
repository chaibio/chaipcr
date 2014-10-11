ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.runExperiment = Backbone.View.extend({

  className: "run-exp-layout",

  initialize: function() {
    this.pasteTopMenu();
    this.pasteGraphContainer();
    this.pasteBottomContainer();
  },

  pasteTopMenu: function() {
    this.nameOnTop = new ChaiBioTech.app.Views.nameOnTop({
      model: this.model
    });
  },

  pasteGraphContainer: function() {
    this.graphContainer = new ChaiBioTech.app.Views.graphContainer({
      model: this.model
    });
  },

  pasteBottomContainer: function() {
    this.bottomContainer =  new ChaiBioTech.app.Views.bottomContainer({
      model: this.model
    });
  },

  render: function() {
    $(this.el).append(this.nameOnTop.render().el);
    $(this.el).append(this.graphContainer.render().el);
    $(this.el).append(this.bottomContainer.render().el);
    return this;
  }
});
