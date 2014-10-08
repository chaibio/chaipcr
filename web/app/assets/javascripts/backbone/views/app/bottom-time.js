ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.bottomTime = Backbone.View.extend({

  className: "bottom-common-item",

  template: JST["backbone/templates/app/bottom-common-item"],

  capsuleTemplate: JST["backbone/templates/app/capsule"],

  initialize: function() {

  },

  render: function() {
    var data = {
      caption: "TIME.",
      data: "0:05"
    }
    $(this.el).html(this.template(data));
    $(this.el).find(".caption-part").append(this.capsuleTemplate());
    $(this.el).find(".ball-cover").draggable({
      containment: "parent",
      axis: "x",
    });
    return this;
  }
});
