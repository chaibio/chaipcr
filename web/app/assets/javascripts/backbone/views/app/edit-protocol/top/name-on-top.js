ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.nameOnTop = Backbone.View.extend({

  className: "name-on-top",

  template: JST["backbone/templates/app/name-on-top"],

  events: {
    "click .stripes": "bringMenuOverlay"
  },

  bringMenuOverlay: function() {

  },

  initialize: function() {
    this.model.on("change:experiment", this.render, this);
  },

  render: function() {

    var data = this.model.get("experiment");
    var dataToTemplate = {
      "name": data.name,
      "id": data.id
    };

    $(this.el).html(this.template(dataToTemplate));
    
    return this;
  }
});
