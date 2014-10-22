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
    console.log(id);
    $("#container").html("Under Construction");
  }

});
