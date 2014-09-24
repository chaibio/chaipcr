ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemperature = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {
    var that = this;
    // Works when step is clicked
    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.changeTemperature(data.circle.temperature.text)
    });
    // Works when circle is dragged
    this.listenTo(this.options.editStepStageClass, "stepDrag", function(data) {
      that.changeTemperature(data.temperature.text);
    });

  },

  changeTemperature: function(temperature) {
    this.dataPart.html(temperature);
  },

  render: function() {
    var data = {
      caption: "TEMPERATURE",
      data: "100.0º"
    }
    $(this.el).html(this.template(data));
    this.dataPart =   $(this.el).find(".data-part");
    return this;
  }
});
