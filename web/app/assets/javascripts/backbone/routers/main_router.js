ChaiBioTech.Routers.PostsRouter = Backbone.Router.extend({

  
  //experimentModel: new ChaiBioTech.Models.Experiment(),
  initialize: function() {
    this.experimentCollection = new ChaiBioTech.Collections.Experiment();
    this.experimentModel = new ChaiBioTech.Models.Experiment();
    this.experimentCollection.reset(this.experimentModel);
    //console.log(this.experimentCollection.models)
  },

  routes: {
    "index": "index",
    "design": "designer",
    ".*": "index"
  },

  index: function() {
    console.log("index");
    var view = new ChaiBioTech.Views.Posts.IndexView();
    $("#container").html(view.render().el);
  },

  designer: function() {
    //console.log("design");
    $.get('experiments', function(data) {
      //console.log('data', data)
    });
    var view = new ChaiBioTech.Views.Design.Index_view();
    $("#container").html(view.render().el);

    var view = new ChaiBioTech.Views.Design.experiment_properties({
        model: this.experimentModel 
      });
    $("#play-ground").html(view.render().el);
  }

});
