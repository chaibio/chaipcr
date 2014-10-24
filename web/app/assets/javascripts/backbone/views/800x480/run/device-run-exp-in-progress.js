ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceExpInProgress = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-exp-in-progress"],

  initialize: function() {
    console.log("this is good");
  },

  render: function() {
    var data = {
      "step": "STEP 1",
      "stage": "STAGE 3",
      "status": "HEATING",
      "time": "01:13:03"
    };

    $(this.el).html(this.template(data));
    return this;
  }
});
