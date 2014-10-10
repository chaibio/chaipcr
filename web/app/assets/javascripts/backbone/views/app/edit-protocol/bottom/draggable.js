ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.draggable = Backbone.View.extend({

  initialize: function() {
    // Here we are writion the behaviour of scroll
    this.options.element.draggable({
      containment: "parent",
      axis: "x",
      // If the user has not dragged the switch to the end..!
      // We auto adjust the position of the switch
      stop: function() {
        var pos = $(this).position().left;
        if(pos < 18) {
          $(this).css("left", "0px");
        } else if(pos >= 18) {
          $(this).css("left", "36px");
        }
      }
    });
    return this.options.element;
  }
});
