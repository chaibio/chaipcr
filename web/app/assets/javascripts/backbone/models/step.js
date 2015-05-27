ChaiBioTech.Models.Step = ChaiBioTech.Models.Step || {};

ChaiBioTech.Models.Step = Backbone.Model.extend({

  url: "/steps",

  initialize: function() {
    // Remember sometimes u will have to assign id
  },

  addStep: function(stageId, fabricStepView) {
    var that = this,
    thisId = this.get("step").id,
    dataToBeSend = {"prev_id": thisId};

    console.log("Data To Server", dataToBeSend);
    $.ajax({
      url: "/stages/"+ stageId +"/steps",
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify(dataToBeSend)
    })
    .done(function(data) {
      //fabricStepView.canvas.clear();
      fabricStepView.canvas.fire("modelChanged", data);
    })
    .fail(function() {
      alert("Failed to update");
      console.log("Failed to update");
    });
  },

  deleteStep: function(stepId, fabricStepView) {
    var that = this;
    $.ajax({
      url: "/steps/"+this.get("step").id,
      contentType: 'application/json',
      type: 'DELETE'
    })
    .done(function(data) {
      fabricStepView.canvas.fire("modelChanged");
    })
    .fail(function() {
      alert("Failed to update");
      console.log("Failed to update");
    });
  },

  changeTemperature: function(newTemp) {
    var that = this;
    var dataToBeSend = {'step':{'temperature': newTemp}};
    $.ajax({
        url: "/steps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
          // Note -: we dont directly update step here, because the returned data doesn't have
          // ramp object, so mostly we change fabric step object.
      })
      .fail(function() {
        console.log("Failed to update");
      });
  },

  gatherDuringStep: function(state) {
    var that = this;
    var dataToBeSend = {'step': {'collect_data': state}};
    $.ajax({
        url: "/steps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function() {
        console.log("Failed to update");
      });
  },

  gatherDataDuringRamp: function(state) {
    var that = this;
    var dataToBeSend = {'ramp': {'collect_data': state}};
    $.ajax({
        url: "/ramps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function() {
        console.log("Failed to update");
      });
  },

  changeRampSpeed: function(rampSpeed) {
    var that = this;
    var dataToBeSend = {'ramp': {'rate': rampSpeed}};
    $.ajax({
        url: "/ramps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function() {
        console.log("Failed to update");
      });
  },

  changeHoldDuration: function(duration) {
    var that = this;
    var dataToBeSend = {'step': {'hold_time': duration}};
    $.ajax({
        url: "/steps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function() {
        console.log("Failed to update");
      });
  },

  saveName: function(stepName) {
    var that = this;
    var dataToBeSend = {'step': {'name': stepName}};
    $.ajax({
        url: "/steps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function() {
        console.log("Failed to update");
      });
  },

  changeDeltaTemperature: function(newTemp) {
    var that = this;
    var dataToBeSend = {'step': {'delta_temperature': newTemp}};
    $.ajax({
        url: "/steps/"+this.get("step").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function() {
        console.log("Failed to update");
      });
  }

});
