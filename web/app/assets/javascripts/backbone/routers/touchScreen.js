ChaiBioTech.Routers.touchScreen = Backbone.Router.extend({

  initialize: function() {
  
  },

  routes: {
    "touchscreen": "touchScreenIndex"
  },

  touchScreenIndex: function() {
    indexPage = new ChaiBioTech.Views.touchScreen.homePage();
    $("body").append(indexPage.render().el);
  }
});
