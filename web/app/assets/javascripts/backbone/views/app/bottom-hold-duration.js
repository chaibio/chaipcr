ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomHoldDuration = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {
    var that  = this;
    this.listenTo(this.options.editStepStageClass, "stepSelected", function(data) {
      that.changeInfo(data)
    });
  },

  changeInfo: function(step) {
    var temp = step.model.get("step").hold_time;
    temp = Math.floor(temp/60) + ":" + temp % 60;
    this.dataPart.html(temp);
    this.dataPartEdit.val(temp);
  },

  render: function() {
    var data = {
      caption: "HOLD DURATION",
      data: "0:30"
    }
    $(this.el).html(this.template(data));
    this.dataPart =   $(this.el).find(".data-part-span");
    this.dataPartEdit = $(this.el).find(".data-part-edit-value");
    return this;
  }
});
