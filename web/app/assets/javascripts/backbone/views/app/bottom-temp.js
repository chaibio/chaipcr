ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTemp = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  capsuleTemplate: JST["backbone/templates/app/capsule"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "TEMP.",
      data: "2.0º"
    }
    $(this.el).html(this.template(data));
    $(this.el).addClass("disabled");
    $(this.el).find(".caption-part").append(this.capsuleTemplate());
    $(this.el).find(".ball-cover").draggable({
      containment: "parent",
      axis: "x",
    });
    return this;
  }
});
