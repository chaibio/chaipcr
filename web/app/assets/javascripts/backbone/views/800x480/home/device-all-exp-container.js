ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceAllExpsContainer = Backbone.View.extend({

  className: "device-all-exp-container",

  initialize: function() {
    this.experimentCollection = new ChaiBioTech.Collections.Experiment();
  },

  getPreviousExperiment: function(coll, data) {
    var allExpInReverse = coll.models.reverse();
    var count = allExpInReverse.length;

    for(var i = 0; i < count; i++) {
      var exp = new ChaiBioTech.app.Views.deviceExpContainer({
        model: allExpInReverse[i]
      });
      // change directly writing class name when u really implement look
      $(".device-all-exp-container").append(exp.render().el);
    }
  },

  loadAllExperiments: function() {
    this.experimentCollection.fetch({success: this.getPreviousExperiment});
  },

  render: function() {
    return this;
  }
})
