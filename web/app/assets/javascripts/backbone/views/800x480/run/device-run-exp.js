ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.deviceRunExp = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-components"],

  className: "device-run-exp-container",

  initialize: function() {
    this.addStripes();
  },

  addStripes: function() {
    this.stripes = new ChaiBioTech.app.Views.deviceRunStripes({
      model: this.model
    });
  },

  render: function() {
    $(this.el).html(this.template());
    $(this.el).find(".device-run-top").append(this.stripes.render().el);
    return this;
  }
});
