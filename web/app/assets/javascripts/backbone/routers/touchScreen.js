ChaiBioTech.Routers.touchScreen = Backbone.Router.extend({

  initialize: function() {

  },

  gotcha: function(coll, respo) {
    indexPage = new ChaiBioTech.Views.touchScreen.homePage({
      collection: coll,
    });
    $("body").html(indexPage.render().el);
    indexPage.populateList();
  },

  routes: {
    "touchscreen": "touchScreenIndex",
    "touchscreen/run/:id": "fireExperiment"
  },

  touchScreenIndex: function() {
    this.experimentCollection = new ChaiBioTech.Collections.Experiment();
    this.experimentCollection.fetch({success: this.gotcha});
  },

  fireExperiment: function(id) {
    run = new ChaiBioTech.Views.touchScreen.runExperiment({
      model: new ChaiBioTech.Models.touchScreenModel,
      id: id
    });
    $("#touchScreenContainer").html(run.render().el);
  }
});
