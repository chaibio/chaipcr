ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceExpInProgress = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-exp-in-progress"],

  initialize: function() {

    var that = this;

    this.runningModel = new ChaiBioTech.Models.RunningExperiment();
    this.runningModel.on("data-updated", function() {
      console.log(this);
      that.render();
      that.timer();
    });

    this.runningModel.getData();
  },

  timer: function() {

    var that = this;
    var time = 60;
    var exp = this.runningModel.get("statusData").heatblock.experimentController.machine.experiment;
    var expStatus = this.runningModel.get("statusData").heatblock.experimentController.machine.status;

    this.timeMachine = window.setInterval(function() {
      var data = {
        "stepNo": exp.step.number,
        "stageNo": exp.stage.number,
        "status": expStatus.toUpperCase(),
        "time": "01:13:"
      }
      time = time - 1;
      var tempTime = (time < 10) ? "0" + String(time) : time;

      data.time = data.time + String(tempTime);
      that.render(data);
      if (time === 0) {
        window.clearInterval(that.timeMachine);
      }
    }, 1000);

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
        "time": "01:13:"
      }
    }

    $(this.el).html(this.template(data));
    return this;
  }
});
