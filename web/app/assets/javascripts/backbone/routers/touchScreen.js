ChaiBioTech.Routers.touchScreen = Backbone.Router.extend({

  initialize: function() {
    
  },

  gotcha: function(coll, respo) {
    indexPage = new ChaiBioTech.Views.touchScreen.homePage({
      collection: coll
    });
    $("body").append(indexPage.render().el);
    indexPage.populateList();
  },

  routes: {
    "touchscreen": "touchScreenIndex"
  },

  touchScreenIndex: function() {
    this.experimentCollection = new ChaiBioTech.Collections.Experiment();
    this.experimentModel = new ChaiBioTech.Models.Experiment();
    this.experimentCollection.fetch({success: this.gotcha});
  }
});
