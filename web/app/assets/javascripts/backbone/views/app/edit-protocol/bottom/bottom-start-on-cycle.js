ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomStartOnCycle = Backbone.View.extend({

  className: "bottom-common-item",

  on: false,

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

    var that = this;
    this.options.editStepStageClass.on("delta_clicked", function() {

      if(that.on) {
        $(that.el).addClass("disabled");
      } else {
        $(that.el).removeClass("disabled");
      }

      that.on = ! that.on;

    });
  },

  render: function() {

    var data = {
      caption: "START ON CYCLE:",
      data: "1"
    };
    $(this.el).html(this.template(data));
    //Disabling for now;
    $(this.el).addClass("disabled");

    return this;
  }
});
