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
    //this.dataPartEdit.val(temp);
    this.lastDuration = temp;
    this.hours = Math.floor(temp/60);
    var hour = (Math.floor(temp/60) < 10) ? "0" + Math.floor(temp/60) : Math.floor(temp/60);
    this.hourSpan.html(hour);
    this.hourEdit.val(hour);
    this.minute = temp % 60;
    var minute = (temp % 60 < 10) ? "0" + temp % 60 : temp % 60;
    this.minuteSpan.html(minute);
    this.minuteEdit.val(minute);
  },

  events: {
      "click .hour-part": "startHourEdit",
      "blur .hour-part-edit": "saveHourAndHide",
      "keydown .hour-part-edit": "seeIfEnterOnHour",
      "click .minute-part": "startMinuteEdit",
      "blur .minute-part-edit": "saveMinuteAndHide",
      "keydown .minute-part-edit": "seeIfEnterOnMinute"
  },

  seeIfEnterOnHour: function(e) {
    if(e.keyCode === 13) {
      this.hourEdit.blur();
    }
  },

  startMinuteEdit: function() {
    this.minuteEdit.show();
    this.minuteEdit.focus();
  },

  saveMinuteAndHide: function() {
    this.minuteEdit.hide();
    var holdMinute= this.minuteEdit.val();
    if(isNaN(holdMinute) || !holdMinute) {
      this.minuteEdit.val(this.lastMinuteValue);
      alert("Please enter a valid value");
    } else {
      holdMinute = parseInt(holdMinute);
      var duration = holdMinute + (this.hours * 60);
      this.currentStep.model.changeHoldDuration(duration);
      this.currentStep.holdDuration = duration;
      var display = (holdMinute < 10) ? "0" + holdMinute : holdMinute;
      this.minuteSpan.html(display);
      this.minuteEdit.val(display);
    }
  },

  seeIfEnterOnMinute: function(e) {
    if(e.keyCode === 13) {
      this.minuteEdit.blur();
    }
  },

  saveHourAndHide: function() {
    this.hourEdit.hide();
    var holdHour = this.hourEdit.val();
    if(isNaN(holdHour) || !holdHour) {
      this.hourEdit.val(this.lastHourValue);
      alert("Please enter a valid value");
    } else {
      holdHour = parseInt(holdHour);
      var duration = (holdHour * 60) + this.minute;
      this.currentStep.model.changeHoldDuration(duration);
      this.currentStep.holdDuration = duration;
      var display = (holdHour < 10) ? "0" + holdHour : holdHour;
      this.hourSpan.html(display);
      this.hourEdit.val(display);
      this.lastHourValue = display;
    }
  },

  startHourEdit: function() {
    this.hourEdit.show();
    this.hourEdit.focus();
  },

  render: function() {
    var data = {
      caption: "HOLD DURATION",
      data: "0:30"
    };
    $(this.el).html(this.template(data));
    this.hourSpan =   $(this.el).find(".hour-part-span");
    this.minuteSpan = $(this.el).find(".minute-part-span");
    this.hourEdit = $(this.el).find(".hour-part-edit");
    this.minuteEdit = $(this.el).find(".minute-part-edit");
    return this;
  }
});
