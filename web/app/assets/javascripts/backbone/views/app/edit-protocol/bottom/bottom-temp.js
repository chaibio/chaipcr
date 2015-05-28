ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemp = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  onState: false,

  capsuleTemplate: JST["backbone/templates/app/capsule"],

  events: {
      "click .data-part": "startEdit",
      "blur .data-part-edit-value": "saveDataAndHide",
      "keydown .data-part-edit-value": "seeIfEnter"
  },

  initialize: function() {

    var that = this;

    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.onState = data.autoDelta;
      that.currentStep = data.currentStep;

      if(that.onState) {
        $(that.el).removeClass("disabled");
        if(! data["systemGenerated"]) {
          that.changeTemp();
        }
      } else {
        $(that.el).addClass("disabled");
      }

    });

    this.options.editStepStageClass.on("stepSelected", function(data) {
      if(that.onState) {
        that.currentStep = data;
        that.changeTemp();
      }
    });

    this.on("signChanged", function(data) {
      that.changeSignForValues();
    })
  },

  startEdit: function() {

    if(this.onState) {
      this.dataPartEdit.show();
      this.dataPartEdit.focus();
    }

  },

  seeIfEnter: function(e) {

    if(e.keyCode === 13) {
      this.dataPartEdit.blur();
    }
  },

  saveDataAndHide: function() {

    var newTemp = this.dataPartEdit.val();
    this.dataPartEdit.hide();


    if(isNaN(newTemp) || !newTemp) {
      var tempVal = this.dataPart.html();

      this.dataPartEdit.val(parseFloat(tempVal.substr(0, tempVal.length - 1)));
      alert("Please enter a valid value");
    } else {
      var newTemp = parseFloat(newTemp).toFixed(1);
      this.currentTemp = newTemp;
      this.currentStep.model.changeDeltaTemperature(newTemp);
      this.dataPart.html(newTemp + "ºc");
      // Now fire it back to canvas
      this.currentStep.updatedDeltaTemp = newTemp;
      this.changeSign(newTemp);
      ChaiBioTech.app.Views.mainCanvas.fire("deltaTemperatureChangedFromBottom", this.currentStep);
    }
  },

  changeTemp: function() {

      this.currentTemp = this.currentStep.model.get("step")["delta_temperature"];
      this.dataPart.html(this.currentTemp + "ºc");
      this.dataPartEdit.val(this.currentTemp);

      this.changeSign(this.currentTemp);
  },

  changeSign: function(val) {

    if(parseFloat(val) > 0) {
      this.draggable.trigger("positive");
    } else {
      this.draggable.trigger("negative");
    }
  },

  changeSignForValues: function() {
    console.log(this.currentTemp)
    this.currentTemp = this.currentTemp * -1;
    this.dataPart.html(this.currentTemp + "ºc");
    this.dataPartEdit.val(this.currentTemp);
    console.log(this.currentTemp)
    this.currentStep.model.changeDeltaTemperature(this.currentTemp);
    // Now fire it back to canvas
    this.currentStep.updatedDeltaTemp = this.currentTemp;
    this.changeSign(this.currentTemp);
    ChaiBioTech.app.Views.mainCanvas.fire("deltaTemperatureChangedFromBottom", this.currentStep);
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
      editStepStageClass: this.options.editStepStageClass,
      parent: this
    });

    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");

    return this;
  }
});
