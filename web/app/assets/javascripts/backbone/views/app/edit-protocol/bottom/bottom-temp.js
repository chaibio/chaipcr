ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemp = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  on: false,

  capsuleTemplate: JST["backbone/templates/app/capsule"],

  events: {
      "click .data-part": "startEdit",
      "blur .data-part-edit-value": "saveDataAndHide",
      "keydown .data-part-edit-value": "seeIfEnter"
  },

  initialize: function() {

    var that = this;
    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.on = data.autoDelta;
      that.currentStep = data.currentStep;

      if(that.on) {
        $(that.el).removeClass("disabled");
        that.changeTemp();
      } else {
        $(that.el).addClass("disabled");
      }

    });

    this.options.editStepStageClass.on("stepSelected", function(data) {
      if(that.on) {
        that.currentStep = data;
        //that.currentTemp = data.model.get("step")["delta_temperature"];
        that.changeTemp();
      }
    });
  },

  startEdit: function() {

    this.dataPartEdit.show();
    this.dataPartEdit.focus();
  },

  seeIfEnter: function(e) {

    if(e.keyCode === 13) {
      this.dataPartEdit.blur();
    }
  },

  saveDataAndHide: function(e) {

    var newTemp = this.dataPartEdit.val();
    this.dataPartEdit.hide();


    if(isNaN(newTemp) || !newTemp || newTemp < 1 || newTemp > 100) {
      var tempVal = this.dataPart.html();

      this.dataPartEdit.val(parseFloat(tempVal.substr(0, tempVal.length - 1)));
      alert("Please enter a valid value");
    } else {
      var newTemp = parseFloat(newTemp).toFixed(1);
      this.currentStep.model.changeDeltaTemperature(newTemp);
      this.dataPart.html(newTemp + "ºc");
      // Now fire it back to canvas
      this.currentStep.updatedDeltaTemp = newTemp;
      ChaiBioTech.app.Views.mainCanvas.fire("deltaTemperatureChangedFromBottom", this.currentStep);
    }
  },
  changeTemp: function() {
      this.currentTemp = this.currentStep.model.get("step")["delta_temperature"];
      this.dataPart.html(this.currentTemp);
      this.dataPartEdit.val(this.currentTemp);
  },

  render: function() {

    var data = {
      caption: "TEMP.",
      data: "2.0º"
    };

    $(this.el).html(this.template(data));
    // Disabling for now
    $(this.el).addClass("disabled");
    $(this.el).find(".caption-part").append(this.capsuleTemplate());

    this.draggable = new ChaiBioTech.app.Views.draggable({
      element: $(this.el).find(".ball-cover"),
      editStepStageClass: this.options.editStepStageClass
    });

    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");

    return this;
  }
});
