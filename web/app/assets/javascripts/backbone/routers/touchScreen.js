ChaiBioTech.Routers.touchScreen = Backbone.Router.extend({

  initialize: function() {
    this.experimentCollection = new ChaiBioTech.Collections.Experiment();
    this.experimentModel = new ChaiBioTech.Models.Experiment();
    this.experimentCollection.fetch({success: this.gotcha});
  },

  gotcha: function(coll, respo) {
    console.log(coll.at(0));
  },

  routes: {
    "touchscreen": "touchScreenIndex"
  },

  touchScreenIndex: function() {
    indexPage = new ChaiBioTech.Views.touchScreen.homePage();
    $("body").append(indexPage.render().el);
  }
});
