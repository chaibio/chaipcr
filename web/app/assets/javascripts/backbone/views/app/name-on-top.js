ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.nameOnTop = Backbone.View.extend({

  className: "name-on-top",

  template: JST["backbone/templates/app/name-on-top"],

  initialize: function() {
    this.model.on("change:experiment", this.render, this);
  },

  render: function() {
    var data = this.model.get("experiment"),
    dataToTemplate = {
      "name": data.name
    };

    $(this.el).html(this.template(dataToTemplate));
    return this;
  }
});
