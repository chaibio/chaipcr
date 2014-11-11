// Plete Layout source code.
(function($){

  $.widget("ChaiBio.plateLayOut", {

    options: {
      value: 0
    },

    _create: function() {
      this._createInterface();
    },

    _init: function() {

      console.log("2 okay", this);
    },

    _createElement: function(element) {

      return $(element);
    },

    _createInterface: function() {

      var divIdentifier = '<div></div>';
      this.container = this._createElement(divIdentifier).addClass("plate-setup-wrapper");
      this.topSection = this._createElement(divIdentifier).addClass("plate-setup-top-section");

      this.topLeft = this._createElement(divIdentifier).addClass("plate-setup-top-left");
      this.topRight = this._createElement(divIdentifier).addClass("plate-setup-top-right");

      this.menuContainer = this._createElement(divIdentifier).addClass("plate-setup-menu-container");
      this.overLayContainer = this._createElement(divIdentifier).addClass("plate-setup-overlay-container");

      $(this.topLeft).append(this.menuContainer);
      $(this.topLeft).append(this.overLayContainer);

      $(this.topSection).append(this.topLeft);
      $(this.topSection).append(this.topRight);

      $(this.container).append(this.topSection);
      $(this.element).html(this.container);

    }

  });
})(jQuery);
