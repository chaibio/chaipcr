ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomHoldDuration = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

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
    this.dataPartEdit.val(temp);
    this.lastDuration = temp;
    temp = Math.floor(temp/60) + ":" + temp % 60;
    this.dataPart.html(temp);
  },

  events: {
      "click .data-part": "startEdit",
      "blur .data-part-edit-value": "saveDataAndHide",
      "keydown .data-part-edit-value": "seeIfEnter"
  },

  seeIfEnter: function(e) {
    if(e.keyCode === 13) {
      this.dataPartEdit.blur();
    }
  },

  saveDataAndHide: function() {
    var newHoldDuration = this.dataPartEdit.val();
    this.dataPartEdit.hide();
    if(isNaN(newHoldDuration) || !newHoldDuration) {
      this.dataPartEdit.val(this.lastDuration);
      alert("Please enter a valid value");
    } else {
      newHoldDuration = parseInt(newHoldDuration);
      this.currentStep.model.changeHoldDuration(newHoldDuration);
      var display = Math.floor(newHoldDuration/60) + ":" + newHoldDuration % 60;;
      this.dataPart.html(display);
      // Now fire it back to canvas
      this.lastDuration = newHoldDuration;
      this.currentStep.holdDuration = newHoldDuration;
      // Fire this if you want something to do in canvas.
      //ChaiBioTech.app.Views.mainCanvas.fire("holdTimeChangedFromBottom", this.currentStep);
    }
  },

  startEdit: function() {
    this.dataPartEdit.show();
    this.dataPartEdit.focus();
  },

  render: function() {
    var data = {
      caption: "HOLD DURATION",
      data: "0:30"
    };
    $(this.el).html(this.template(data));
    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");
    return this;
  }
});
