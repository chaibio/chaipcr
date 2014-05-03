ChaiBioTech.Routers.touchScreen = Backbone.Router.extend({

  initialize: function() {
    
  },

  gotcha: function(coll, respo) {
    console.log(coll.at(0));
    indexPage = new ChaiBioTech.Views.touchScreen.homePage({
      collection: coll
    });
    $("body").append(indexPage.render().el);
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
