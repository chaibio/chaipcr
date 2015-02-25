ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomRampSpeed = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

    var that = this;
    // Works when step is clicked
    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.currentStep = data;
      that.changeRampSpeed();
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

  saveDataAndHide: function() {

    var newRampSpeed = this.dataPartEdit.val();

    this.dataPartEdit.hide();

    if(isNaN(newRampSpeed) || !newRampSpeed || newRampSpeed < 0 || newRampSpeed > 100) {
      var tempVal = this.dataPart.html();

      this.dataPartEdit.val(tempVal);
      alert("Please enter a valid value");
    } else {

      newRampSpeed = parseFloat(newRampSpeed);

      var tempNumberString = String(newRampSpeed);
      var numberArray = tempNumberString.split(".");

      if(numberArray.length === 2) {
        if(numberArray[1].length > 6) {
          newRampSpeed = newRampSpeed.toFixed(6);
        }
      } else if (numberArray.length === 1) {
        newRampSpeed = newRampSpeed.toFixed(1);
      }
      this.currentStep.model.changeRampSpeed(newRampSpeed);

      var display = (newRampSpeed === 0 || newRampSpeed > 5) ? "MAX" : newRampSpeed;

      if (newRampSpeed > 5) {
        newRampSpeed = 5;
      }

      this.dataPart.html(display);
      // Now fires it back to canvas
      this.currentStep.rampSpeedNumber = newRampSpeed;
      ChaiBioTech.app.Views.mainCanvas.fire("rampSpeedChangedFromBottom", this.currentStep);

      // Detecting RampSpeed new width
      var newRampSpeedWidth = this.dataPart.width();
      if (newRampSpeedWidth > 95) {
        this.dataPart.addClass('minified-font');
      } else {
        this.dataPart.removeClass('minified-font')
      }

    }
  },

  seeIfEnter: function(e) {

    if(e.keyCode === 13) {
      this.dataPartEdit.blur();
    }
  },

  changeRampSpeed: function() {

    if(this.currentStep.rampSpeedNumber === 0) {
      this.dataPart.html("MAX");
      this.dataPartEdit.val(0)
    } else if (this.currentStep.rampSpeedNumber >= 5) {
      this.dataPart.html("MAX");
      this.dataPartEdit.val(5)
    } else {
      this.dataPart.html(this.currentStep.rampSpeedNumber);
      this.dataPartEdit.val(parseFloat(this.currentStep.rampSpeedNumber));
    };

    // Detecting RampSpeed new width
    var newRampSpeedWidth = this.dataPart.width();
    if (newRampSpeedWidth > 95) {
      this.dataPart.addClass('minified-font');
    } else {
      this.dataPart.removeClass('minified-font')
    }
  },

  render: function() {

    var data = {
      caption: "RAMP SPEED",
      data: "MAX"
    };

    $(this.el).html(this.template(data));
    this.dataPart = $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");
    
    return this;
  }
});
