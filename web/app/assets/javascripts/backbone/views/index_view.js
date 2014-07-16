ChaiBioTech.Views.Posts = ChaiBioTech.Views.Posts || {} ;

ChaiBioTech.Views.Posts.IndexView = Backbone.View.extend({
  
  template: JST["backbone/templates/index"],

  events: {
    'click #design-button': 'goToDesign',
    'click #login-button': 'goToLogin'
  },

  initialize: function() {

  },

  goToDesign: function() {
    document.location.hash = "#/design";
  },

  goToLogin: function () {
    document.location.hash = "#/login";
  },

  render: function() {
    $(this.el).html(this.template());
    return this;
  }

});
  
