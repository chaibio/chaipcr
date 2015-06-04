ChaiBioTech.Models.Stage = ChaiBioTech.Models.Stage || {};

ChaiBioTech.Models.Stage = Backbone.Model.extend({

  url: "/protocols",

  initialize: function() {
    // Remember sometimes u will have to assign id
  },

  addStage: function(type, protocolId, fabricStageView) {
    that = this;
    var id = this.get("stage").id;
    var dataToBeSend = {
      "prev_id": id,
      "stage": {
        'stage_type': type
      }
    };
    $.ajax({
      url: "/protocols/"+protocolId+"/stages",
      contentType: 'application/json',
      type: 'POST',
      data: JSON.stringify(dataToBeSend)
    })
    .done(function(data) {
      fabricStageView.canvas.fire("modelChanged", data);
    })
    .fail(function() {
      console.log("Failed to update");
    });
  },

  saveCycle: function(cycle) {
    var that = this;
    var dataToBeSend = {'stage': {'num_cycles': cycle}};
    $.ajax({
        url: "/stages/"+this.get("stage").id,
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

  updateAutoDelata: function(newDelta) {

    var that = this;
    var dataToBeSend = {'stage': {'auto_delta': newDelta}};

    console.log(dataToBeSend);
    $.ajax({
        url: "/stages/"+this.get("stage").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function(err) {
        console.log("Failed to update", err);
      });

  },

  changeStartOnCycle: function(soc) {
    var that = this;
    var dataToBeSend = {'stage': {'auto_delta_start_cycle': soc}};

    console.log(dataToBeSend);
    $.ajax({
        url: "/stages/"+this.get("stage").id,
        contentType: 'application/json',
        type: 'PUT',
        data: JSON.stringify(dataToBeSend)
      })
      .done(function(data) {
          console.log("Data updated from server woohaa" , data);
      })
      .fail(function(err) {
        console.log("Failed to update", err);
      });
  }
});
