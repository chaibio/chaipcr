ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.deviceRunExpName = Backbone.View.extend({

  className: "device-run-exp-name-container",

  template: JST["backbone/templates/800x480/run/device-run-exp-name"],

  initialize: function() {
    //console.log("ddddd")
  },

  render: function() {
    var data = {
      "name": this.model.get("experiment").name
    };

    $(this.el).html(this.template(data));
    return this;
  }
});
