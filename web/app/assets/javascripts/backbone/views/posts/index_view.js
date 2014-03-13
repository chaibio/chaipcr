ChaiBioTech.Views.Posts = ChaiBioTech.Views.Posts || {} ;

ChaiBioTech.Views.Posts.IndexView = Backbone.View.extend({
  
  template: JST["backbone/templates/posts/index"],

  events: {
    'click #design-button': 'goToDesign'
  },

  initialize: function() {

  },

  goToDesign: function() {
    document.location.hash = "#/design";
  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }

});
  
