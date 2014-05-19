ChaiBioTech.Routers.DesignRouter = Backbone.Router.extend({

  initialize: function() {
    this.experimentCollection = new ChaiBioTech.Collections.Experiment();
    this.experimentModel = new ChaiBioTech.Models.Experiment();
    //this.experimentCollection.fetch(/*{success: this.gotcha}*/);
  },

  /*gotcha: function(coll, respo) {
    console.log(coll.at(0), respo);
  },*/

  routes: {
    "index": "index",
    "design": "designer",
    "design/run": "runMethod",
    ".*": "index"
  },

  index: function() {
    console.log("index");
    var view = new ChaiBioTech.Views.Posts.IndexView();
    $("#container").html(view.render().el);
  },

  designer: function() {
    console.log(this.experimentCollection)
    var view = new ChaiBioTech.Views.Design.Index_view();
    $("#container").html(view.render().el);

    var view = new ChaiBioTech.Views.Design.experiment_properties({
        model: this.experimentModel
      });
    $("#play-ground").html(view.render().el);
  },

  runMethod: function() {
    //if(_.has(this.experimentModel.get("experiment"), "id")) {
      this.runView = new ChaiBioTech.Views.Design.runExperiment({
        model: this.experimentModel
      });
      $("#play-ground").html(this.runView.render().el);
      this.runView.addStages();
   //}else {
      //alert("Please create an experiment before run ")
    //}
  }

});
