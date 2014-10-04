ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemperature = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {
    var that = this;
    // Works when step is clicked
    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.currentStep = data;
      that.changeTemperature(data.circle.temperature.text);
    });
    // Works when circle is dragged
    this.listenTo(this.options.editStepStageClass, "stepDrag", function(data) {
      that.currentStep = data;
      that.changeTemperature(data.temperature.text);
    });
  },

  events: {
      "click .data-part": "startEdit",
      "blur .data-part-edit-value": "saveDataAndHide",
      "keydown .data-part-edit-value": "seeIfEnter"
  },

  startEdit: function() {
    this.dataPartEdit.show();
    this.dataPartEdit.focus();
  },

  seeIfEnter: function(e) {
    if(e.keyCode === 13) {
      // Hiding this inturn fires blur event
      this.dataPartEdit.blur();
    }
  },

  saveDataAndHide: function(e) {
    var newTemp = this.dataPartEdit.val();
    this.dataPartEdit.hide();
    if(isNaN(newTemp) || !newTemp || newTemp < 0 || newTemp > 100) {
      var tempVal = this.dataPart.html()
      this.dataPartEdit.val(parseFloat(tempVal.substr(0, tempVal.length - 1)));
      alert("Please enter a valid value");
    } else {
      newTemp = parseFloat(newTemp).toFixed(1);
      this.currentStep.model.changeTemperature(newTemp);
      this.dataPart.html(newTemp + "º");
      // Now fire it back to canvas
      this.currentStep.circle.temperatureValue = newTemp;
      ChaiBioTech.app.Views.mainCanvas.fire("temperatureChangedFromBottom", this.currentStep);
    }
  },

  changeTemperature: function(temperature) {
    this.dataPart.html(temperature);
    this.dataPartEdit.val(parseFloat(temperature.substr(0, temperature.length - 1)));
  },

  render: function() {
    var data = {
      caption: "TEMPERATURE",
      data: "100.0º"
    }
    $(this.el).html(this.template(data));
    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");
    return this;
  }
});
