ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceExpInProgress = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-exp-in-progress"],

  initialize: function() {

    var that = this;

    this.runningModel = new ChaiBioTech.Models.RunningExperiment();
    this.runningModel.on("data-updated", function() {
      console.log(this);
      that.render();
    });

    this.runningModel.getData();

  },

  render: function(data) {

    if(!data) {
      var exp = this.runningModel.get("statusData").heatblock.experimentController.machine.experiment;
      var expStatus = this.runningModel.get("statusData").heatblock.experimentController.machine.status;
      console.log(exp);
      var data = {
        "stepNo": exp.step.number,
        "stageNo": exp.stage.number,
        "status": expStatus.toUpperCase(),
        "time": "01:13:03"
      }
    }

    $(this.el).html(this.template(data));
    return this;
  }
});
