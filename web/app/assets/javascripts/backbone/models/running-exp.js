ChaiBioTech.Models.RunningExperiment = Backbone.Model.extend({

  defaults: {

  },

  initialize: function() {

  },

  getData: function() {
    var that = this;
    $.ajax({
      url: "http://localhost:4000/status",
      contentType: 'application/json',
      type: 'GET',
      dataType: 'jsonp',
      jsonpCallback: 'updateRecordDisplay'
    })
    .done(function(data) {
      that.set("statusData", data);
      that.trigger("data-updated");
    });
  }
});
