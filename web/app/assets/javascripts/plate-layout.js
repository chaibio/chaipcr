// Plete Layout source code.
(function($, fabric){

  $.widget("DNA.plateLayOut", {

    options: {
      value: 0
    },

    _create: function() {
      this._createInterface();
    },

    _init: function() {

      //console.log("2 okay", this);
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
      this.canvasContainer = this._createElement(divIdentifier).addClass("plate-setup-canvas-container");

      this._createMenu();
      $(this.topLeft).append(this.menuContainer);

      this._createOverLay();
      $(this.topLeft).append(this.overLayContainer);

      this._createCanvas();
      $(this.topLeft).append(this.canvasContainer);


      $(this.topSection).append(this.topLeft);
      $(this.topSection).append(this.topRight);

      $(this.container).append(this.topSection);
      $(this.element).html(this.container);

      this._initiateFabricCanvas();

      this._createTabAtRight();
    },

    _createCanvas: function() {

      this.normalCanvas = this._createElement("<canvas>").attr("id", "DNAcanvas");
      $(this.canvasContainer).append(this.normalCanvas);
    },

    _createTabAtRight: function() {
      this.tabContainer = this._createElement("<div></div>").addClass("plate-setup-tab-container");
      $(this.topRight).append(this.tabContainer);
    },

    _createOverLay: function() {

      this.radioContainer = this._createElement("<div></div>").addClass("plate-setup-overlay-radio-container");
      $(this.overLayContainer).append(this.radioContainer);
      this.overLayTextContainer = this._createElement("<div></div>").addClass("plate-setup-overlay-text-container");
      $(this.overLayTextContainer).html("Overlay % Complete");
      $(this.overLayContainer).append(this.overLayTextContainer);
      this.overLayButtonContainer = this._createElement("<div></div>").addClass("plate-setup-overlay-button-container");
      $(this.overLayContainer).append(this.overLayButtonContainer);

      this.copyCrieteriaButton = this._createElement("<button />").addClass("plate-setup-button");
      $(this.copyCrieteriaButton).text("Copy Criteria");
      $(this.overLayButtonContainer).append(this.copyCrieteriaButton);

      this.pasteCrieteriaButton = this._createElement("<button />").addClass("plate-setup-button");
      $(this.pasteCrieteriaButton).text("Paste Criteria");
      $(this.overLayButtonContainer).append(this.pasteCrieteriaButton);
    },

    _initiateFabricCanvas: function() {

      this.mainFabricCanvas = new fabric.Canvas('DNAcanvas', {
        backgroundColor: '#f5f5f5',
        selection: true,
        stateful: true
      })
      .setWidth(632)
      .setHeight(482);
    },

    _createMenu: function() {

      var menuItems = {
        "File..": {},
        "Undo": {},
        "Redo": {},
        "Templates": {}
      };

      var menuContent = null;

      for(menuItem in menuItems) {
        menuContent = this._createElement("<div></div>")
        .html(menuItem)
        .addClass("plate-setup-menu-item");

        $(menuContent).on("click", function() {
          console.log("okay menu");
          //Code for click event may be will have to implement poping menu here.
        });

        $(this.menuContainer).append(menuContent);
      }

    }

  });
})(jQuery, fabric);
