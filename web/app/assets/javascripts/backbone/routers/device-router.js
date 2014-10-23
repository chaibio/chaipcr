ChaiBioTech.Routers.deviceRouter = Backbone.Router.extend({

  routes: {
    "800x480-home": "deviceHome",
    "800x480-run-exp/:id": "deviceRunExp"
  },

  initialize: function() {
    console.log("initialized");
  },

  deviceHome: function() {
    this.deviceHomeContainer = new ChaiBioTech.app.Views.deviceHomeContainer();
    $("#container").html(this.deviceHomeContainer.render().el);
  },

  deviceRunExp: function(id) {
    var that = this;
    callback = function() {
      that.deviceRunExp = new ChaiBioTech.app.Views.deviceRunExp({
        model: expModel
      });
      $("#container").html(that.deviceRunExp.render().el);
    };
    expModel = new ChaiBioTech.Models.Experiment({"id": id, "callback": callback});
  }

});
