ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.deviceExpContainer = Backbone.View.extend({

  className: "device-exp-container",

  template: JST["backbone/templates/800x480/home/device-exp"],

  initialize: function() {
    
  },

  render: function() {
    var data = {
      "name": this.model.get("experiment").name,
      "id": this.model.get("experiment").id
    };

    $(this.el).html(this.template(data));
    return this;
  }
});
