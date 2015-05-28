ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomHoldDuration = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-hold-duration"],

  lastDuration: null,

  initialize: function() {

    var that  = this;

    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      this.currentStep = data;
      that.changeInfo(data);
    });
  },

  changeInfo: function(step) {

    var temp = this.currentStep.holdDuration || step.model.get("step").hold_time;

    this.lastDuration = temp;
    this.hours = Math.floor(temp/60);

    var hour = (Math.floor(temp/60) < 10) ? "0" + Math.floor(temp/60) : Math.floor(temp/60);
    var minute = (temp % 60 < 10) ? "0" + temp % 60 : temp % 60;

    this.timeSpan.html(hour + ":" + minute);
    this.timeEdit.val(hour + ":" + minute);
    this.minute = temp % 60;
  },

  events: {
      "click .time-part": "startHourEdit",
      "blur .time-part-edit": "saveTimeAndHide",
      "keydown .time-part-edit": "seeIfEnterOnHour",
  },

  seeIfEnterOnHour: function(e) {

    if(e.keyCode === 13) {
      this.timeEdit.blur();
    }
  },

  saveTimeAndHide: function() {

    this.timeEdit.hide();

    var holdTime = this.timeEdit.val();

    var value = holdTime.indexOf(":");
    if(value != -1) {
      var hr = holdTime.substr(0, value);
      var min = holdTime.substr(value + 1);

      if(isNaN(hr) || isNaN(min)) {
        holdTime = null;
      } else {
        holdTime = (hr * 60) + (min * 1);
      }
    }

    if(isNaN(holdTime) || !holdTime) {
      this.timeEdit.val(this.lastHourValue);
      alert("Please enter a valid value");
    } else {
      holdTime = parseInt(holdTime);

      this.currentStep.model.changeHoldDuration(holdTime);
      this.currentStep.holdDuration = holdTime;

      var hour = (Math.floor(holdTime/60) < 10) ? "0" + Math.floor(holdTime/60) : Math.floor(holdTime/60);
      var minute = (holdTime % 60 < 10) ? "0" + holdTime % 60 : holdTime % 60;

      var display = hour + ":" + minute;

      this.timeSpan.html(display);
      this.timeEdit.val(display);
      this.lastHourValue = holdTime;
      ChaiBioTech.app.Views.mainCanvas.fire("holdTimeChangedFromBottom", this.currentStep);
    }
  },

  startHourEdit: function() {

    this.timeEdit.show();
    this.timeEdit.focus();
  },

  render: function() {

    var data = {
      caption: "HOLD DURATION",
      data: "0:30"
    };

    $(this.el).html(this.template(data));
    this.timeSpan =   $(this.el).find(".time-part-span");
    //this.minuteSpan = $(this.el).find(".minute-part-span");
    this.timeEdit = $(this.el).find(".time-part-edit");
    //this.minuteEdit = $(this.el).find(".minute-part-edit");

    return this;
  }
});
