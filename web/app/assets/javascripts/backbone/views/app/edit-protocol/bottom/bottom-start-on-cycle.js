ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomStartOnCycle = Backbone.View.extend({

  className: "bottom-common-item",

  onState: false,

  template: JST["backbone/templates/app/bottom-common-item"],

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
          that.changeStartOnCycle();
        }
      } else {
        $(that.el).addClass("disabled");
      }

    });

    this.options.editStepStageClass.on("stepSelected", function(data) {
      if(that.onState) {
        that.currentStep = data;
        that.changeStartOnCycle();
      }
    });
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

  saveDataAndHide: function(e) {

    var newStartOnCycle = this.dataPartEdit.val();
    this.dataPartEdit.hide();
    var noOfCycles = this.currentStep.parentStage.model.get("stage")["num_cycles"];

    if(isNaN(newStartOnCycle) || !newStartOnCycle || newStartOnCycle < 1 || newStartOnCycle > 100) {
      var tempVal = this.dataPart.html();

      this.dataPartEdit.val(parseInt(tempVal));
      alert("Please enter a valid value");
    } else if(newStartOnCycle > noOfCycles) {
      var tempVal = this.dataPart.html();

      this.dataPartEdit.val(parseInt(tempVal));
      alert("New value cannot be greater than the total number of cycles");
    } else {
      var tempVal = parseInt(newStartOnCycle);

      this.currentStep.parentStage.model.changeStartOnCycle(tempVal);
      this.dataPart.html(newStartOnCycle);
      // Now fire it back to canvas

      var data = {
        "stage": this.currentStep.parentStage,
        soc: tempVal
      };

      ChaiBioTech.app.Views.mainCanvas.fire("startOnCycleChangedFromBottom", data);
    }
  },

  changeStartOnCycle: function() {

      this.currentStartOnCycle = this.currentStep.parentStage.model.get("stage")["auto_delta_start_cycle"];
      this.dataPart.html(this.currentStartOnCycle);
      this.dataPartEdit.val(this.currentStartOnCycle);
  },

  render: function() {

    var data = {
      caption: "START ON CYCLE:",
      data: "1"
    };
    $(this.el).html(this.template(data));
    //Disabling for now;
    $(this.el).addClass("disabled");

    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");

    return this;
  }
});
