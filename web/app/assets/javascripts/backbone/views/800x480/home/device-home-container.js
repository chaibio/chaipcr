ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceHomeContainer = Backbone.View.extend({

  className: "device-home-container",

  initialize: function() {
    //bring all exps Container here;
    this.allExpsContainer = new ChaiBioTech.app.Views.deviceAllExpsContainer();
  },

  render: function() {
    $(this.el).append(this.allExpsContainer.render().el);
    this.allExpsContainer.loadAllExperiments();
    return this;
  }
})
