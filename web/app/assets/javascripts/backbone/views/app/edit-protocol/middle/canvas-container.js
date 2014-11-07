ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.canvasContainer = Backbone.View.extend({

  className: "canvas-containing",

  initialize: function() {

    this.canvas = new ChaiBioTech.app.Views.canvas();
  },

  render: function() {

    $(this.el).html(this.canvas.el);
    
    return this;
  }

});
