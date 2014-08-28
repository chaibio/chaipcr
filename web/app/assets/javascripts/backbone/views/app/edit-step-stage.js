ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.editStageStep = Backbone.View.extend({

  className: "edit-stage-step-container",

  template: JST["backbone/templates/app/edit-stage-step"],

  initialize: function() {
    this.pasteName();
  },

  pasteName: function() {
    this.nameOnTop = new ChaiBioTech.app.Views.nameOnTop();
  },

  render: function() {
    $(this.el).html(this.template());
    $(this.el).find(".top-half").append(this.nameOnTop.render().el);
    return this;
  }
});
