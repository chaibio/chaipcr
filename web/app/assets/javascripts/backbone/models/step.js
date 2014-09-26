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
      fabricStepView.canvas.fire("modelChanged");
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
      console.log(data);
      fabricStepView.canvas.fire("modelChanged");
    })
    .fail(function() {
      alert("Failed to update");
      console.log("Failed to update");
    });
  },

  changeTemperature: function(newTemp) {
    that = this;
    dataToBeSend = {'step':{'temperature': newTemp}}
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
      })
  }


});
