ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTime = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  onState: false,

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
          that.changeTime();
        }
      } else {
        $(that.el).addClass("disabled");
      }
    });

    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      if(that.onState) {
        that.currentStep = data;
        that.changeTime();
      }
    });

    this.on("signChanged", function(data) {
      that.changeSignForValues();
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

    this.dataPartEdit.hide();

    var deltaTime = this.dataPartEdit.val();

    var value = deltaTime.indexOf(":");
    if(value != -1) {
      var hr = deltaTime.substr(0, value);
      var min = deltaTime.substr(value + 1);

      if(isNaN(hr) || isNaN(min)) {
        deltaTime = null;
      } else {
        deltaTime = (hr * 60) + (min * 1);
      }
    }

    if(isNaN(deltaTime) || !deltaTime) {
      this.dataPartEdit.val(this.dataPart.html());
      alert("Please enter a valid value");
    } else {
      deltaTime = parseInt(Math.abs(deltaTime));

      this.currentStep.model.changeDeltaTime(deltaTime);
      this.currentStep.deltaTime = deltaTime;
      this.currentDelta = deltaTime;
      var hour = (Math.floor(deltaTime/60) < 10) ? "0" + Math.floor(deltaTime/60) : Math.floor(deltaTime/60);
      var minute = (deltaTime % 60 < 10) ? "0" + deltaTime % 60 : deltaTime % 60;

      var display = hour + ":" + minute;

      this.dataPart.html(display);
      this.dataPartEdit.val(display);
      this.changeSign(deltaTime);
      ChaiBioTech.app.Views.mainCanvas.fire("deltaTimeChangedFromBottom", this.currentStep);
    }
  },

  changeTime: function() {

    var deltaTime = this.currentStep.model.get("step")["delta_duration_s"];

    this.currentStep.deltaTime = deltaTime;
    deltaTime = Math.abs(deltaTime);

    var hour = (Math.floor(deltaTime/60) < 10) ? "0" + Math.floor(deltaTime/60) : Math.floor(deltaTime/60);
    var minute = (deltaTime % 60 < 10) ? "0" + deltaTime % 60 : deltaTime % 60;

    var display = hour + ":" + minute;

    this.dataPart.html(display);
    this.dataPartEdit.val(display);
    this.changeSign(this.currentStep.deltaTime);
  },

  changeSign: function(val) {

    if(parseFloat(val) > 0) {
      this.draggable.trigger("positive");
    } else if(parseFloat(val) < 0) {
      this.draggable.trigger("negative");
    }
  },

  changeSignForValues: function() {

    this.currentStep.deltaTime = this.currentStep.deltaTime * -1;

    this.currentStep.model.changeDeltaTime(this.currentStep.deltaTime);
    this.deltaTime = this.currentStep.deltaTime;
    this.changeSign(this.deltaTime);
    // Now fire it back to canvas
    ChaiBioTech.app.Views.mainCanvas.fire("deltaTimeChangedFromBottom", this.currentStep);
  },

  render: function() {

    var data = {
      caption: "TIME.",
      data: "0:05"
    };

    $(this.el).html(this.template(data));
    // Disabiling for now.
    $(this.el).addClass("disabled");

    this.draggable = new ChaiBioTech.app.Views.draggable({
      editStepStageClass: this.options.editStepStageClass,
      parent: this
    });

    $(this.el).find(".caption-part").append(this.draggable.render().el);


    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");

    return this;
  }
});
