ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.editStageStep = Backbone.View.extend({

  className: "edit-stage-step-container",

  template: JST["backbone/templates/app/edit-stage-step"],

  initialize: function() {
    this.pasteName();
    this.pasteCanvasContainer();
  },

  pasteName: function() {
    this.nameOnTop = new ChaiBioTech.app.Views.nameOnTop({
      model: this.model
    });
  },

  pasteCanvasContainer: function() {
    this.canvasContainer = new ChaiBioTech.app.Views.canvasContainer();
  },

  render: function() {
    $(this.el).html(this.template());
    var topHalf = $(this.el).find(".top-half");
    topHalf.append(this.nameOnTop.render().el);
    topHalf.append(this.canvasContainer.el);
    return this;
  }
});
