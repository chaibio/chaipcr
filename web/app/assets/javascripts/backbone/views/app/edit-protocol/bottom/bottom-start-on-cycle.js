ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomStartOnCycle = Backbone.View.extend({

  className: "bottom-common-item",

  on: false,

  template: JST["backbone/templates/app/bottom-common-item"],

  initialize: function() {

    var that = this;
    this.options.editStepStageClass.on("delta_clicked", function(data) {

      that.on = data.autoDelta;

      if(that.on) {
        $(that.el).removeClass("disabled");
      } else {
        $(that.el).addClass("disabled");
      }

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
