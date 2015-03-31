// Plate Layout source code.
(function($, fabric){

  $.widget("DNA.plateLayOut", {

    options: {
      value: 0
    },

    columnCount: 12,

    rowIndex: ["A", "B", "C", "D", "E", "F", "G", "H"],

    allTabs: [],

    allDataTabs: [], // To hold all the tab contents. this contains all the tabs and its elements and elements
    // Settings as a whole. its very usefull, when we have units for a specific field.
    // it goes like tabs-> individual field-> units and checkbox

    _create: function() {

      console.log(this.options.imgSrc);
      this.imgSrc = this.options.imgSrc || "assets",
      this._createInterface();
    },

    _init: function() {

      // This is invoked when the user use the plugin after _create is callsed.
      // The point is _create is invoked for the very first time and for all other
      // times _init is used.
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
      this._createTabs();

      this._placeWellAttr();
      this._placeWellAttrTabs();
      // Bottom of the screen
      this._bottomScreen();
      // Canvas
      this._canvas();

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

      //this.radioContainer = this._createElement("<div></div>").addClass("plate-setup-overlay-radio-container");
      //$(this.overLayContainer).append(this.radioContainer);
      this.overLayTextContainer = this._createElement("<div></div>").addClass("plate-setup-overlay-text-container");
      $(this.overLayTextContainer).html("Completion Percentage:");
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
        "Templates": {},
        "Redo": {},
        "Undo": {}
      };

      var menuContent = null;

      for(var menuItem in menuItems) {
        menuContent = this._createElement("<div></div>")
        .html(menuItem)
        .addClass("plate-setup-menu-item");

        $(menuContent).on("click", function() {
          console.log("okay menu");
          //Code for click event. May be will have to implement poping menu here.
        });

        $(this.menuContainer).append(menuContent);
      }

    },

    _createTabs: function() {
      // this could be done using z-index. just imagine few cards stacked up.
      // Check if options has tab data.
      // Originally we will be pulling tab data from developer.
      // Now we are building upon dummy data.
      this.tabHead = this._createElement("<div></div>").addClass("plate-setup-tab-head");
      $(this.tabContainer).append(this.tabHead);

      var tabData = this.options.attributes;

      var tabIndex = 0;

      for(var tab in tabData) {
        this.allTabs[tabIndex ++] = this._createElement("<div></div>").addClass("plate-setup-tab");
        $(this.allTabs[tabIndex - 1]).data("index", tabIndex - 1)
        .html(tab);

        var that = this;

        $(this.allTabs[tabIndex - 1]).click(function() {
          that._tabClickHandler(this);
        });

        $(this.tabHead).append(this.allTabs[tabIndex - 1]);

      }

      this.tabDataContainer = this._createElement("<div></div>").addClass("plate-setup-tab-data-container");
      $(this.tabContainer).append(this.tabDataContainer);

      this._addDataTabs(tabData);

      $(this.allTabs[0]).click();

      this._addTabData();
    },

    _tabClickHandler: function(clickedTab) {

      if(this.selectedTab) {
        $(this.selectedTab).removeClass("plate-setup-tab-selected")
        .addClass("plate-setup-tab");

        var previouslyClickedTabIndex = $(this.selectedTab).data("index");
        $(this.allDataTabs[previouslyClickedTabIndex]).css("z-index", 0);
      }

      $(clickedTab).addClass("plate-setup-tab-selected");

      this.selectedTab = clickedTab;
      //console.log(this.allDataTabs[$(this.selectedTab).data("index")]);
      var clickedTabIndex = $(clickedTab).data("index");
      $(this.allDataTabs[clickedTabIndex]).css("z-index", 1000);
    },

    _addDataTabs: function(tabs) {

      var tabIndex = 0;

      for(var tabData in tabs) {
        this.allDataTabs[tabIndex ++] = this._createElement("<div></div>").addClass("plate-setup-data-div")
        .css("z-index", 0);
        $(this.tabDataContainer).append(this.allDataTabs[tabIndex - 1]);
      }
    },

    _placeWellAttr: function() {

      this.wellAttrContainer = this._createElement("<div></div>").addClass("plate-setup-well-attr-container")
      .html("Well Attribute Tabs");
      $(this.tabContainer).append(this.wellAttrContainer);
    },

    _placeWellAttrTabs: function() {

      this.presetTabContainer = this._createElement("<div></div>").addClass("plate-setup-preset-container");
      $(this.tabContainer).append(this.presetTabContainer);
      // From where I am going to get this data ??
      var wellAttrData = {
        "Preset 1": {

        },

        "Preset 2": {

        },

        "Preset 3": {

        },

        "Preset 4": {

        }
      }

      var presetArray = [];
      var counter = 0;
      for(var preset in wellAttrData) {
        var divText = this._createElement("<div></div>").html(preset)
        .addClass("plate-setup-prest-tab-div");
        presetArray[counter ++] = this._createElement("<div></div>").addClass("plate-setup-prest-tab")
        .append(divText);
        $(this.presetTabContainer).append(presetArray[counter - 1]);

        var that = this;

        $(presetArray[counter - 1]).click(function() {
          that._presetClickHandler(this);
        });
      }
    },

    _presetClickHandler: function(clickedPreset) {

      if(this.previouslyClickedPreset) {
        $(this.previouslyClickedPreset).removeClass("plate-setup-prest-tab-selected")
        .addClass("plate-setup-prest-tab");
      }

      $(clickedPreset).addClass("plate-setup-prest-tab-selected");
      this.previouslyClickedPreset = clickedPreset;
      // What does preset tabs do ??
    },

    _bottomScreen: function() {

      this.bottomContainer = this._createElement("<div></div>").addClass("plate-setup-bottom-container");
      $(this.container).append(this.bottomContainer);
    },

    _canvas: function() {
      // Those 1,2,3 s and A,B,C s
      this._fixRowAndColumn();

      // All those circles in the canvas.
      this._putCircles();

    },

    _fixRowAndColumn: function() {

      // For column
      for(var i = 1; i<= this.columnCount; i++) {
        var tempFabricText = new fabric.IText(i.toString(), {
          fill: 'black',
          originX:'center',
          originY: 'center',
          fontSize: 12,
          top : 10,
          left: 48 + ((i - 1) * 48),
          fontFamily: "Roboto",
          selectable: false,
          fontWeight: "400"
        });

        this.mainFabricCanvas.add(tempFabricText);
      }

      // for row
      var i = 0;
      while(this.rowIndex[i]) {
        var tempFabricText = new fabric.IText(this.rowIndex[i], {
          fill: 'black',
          originX:'center',
          originY: 'center',
          fontSize: 12,
          left: 5,
          top: 48 + (i * 48),
          fontFamily: "Roboto",
          selectable: false,
          fontWeight: "400"
        });

        this.mainFabricCanvas.add(tempFabricText);
        i ++;
      }
    },

    _putCircles: function() {

      var rowCount = this.rowIndex.length;
      for( var i = 0; i < rowCount; i++) {

        for(var j = 0; j < 12; j++) {
          var tempCircle = new fabric.Circle({
            radius: 14,
            strokeWidth: 17,
            stroke: 'purple',
            originX:'center',
            originY: 'center',
            left: 48 + (j * 48),
            top: 48 + (i * 48),
            hasBorders: false,
            fill: 'white',
            selectable: true,
            hasBorders: false,
            hasControls: false,
            hasRotatingPoint: false,
            name: "circle"
          });

          this.mainFabricCanvas.add(tempCircle);
        }
      }
    },

    // We have tabs content in options , and her we put it in those tabs which are already placed
    _addTabData: function() {

      // Here we may need more changes becuse attributes format likely to change
      var tabData = this.options["attributes"];
      var tabPointer = 0;

      for(currentTab in tabData) {
        if(tabData[currentTab]["fields"]) {
          var fieldArray = [];
          var fieldArrayIndex = 0;
          // Now we look for fields in the json
          for(field in tabData[currentTab]["fields"]) {
            var data = tabData[currentTab]["fields"][field];
            var input = "";
            // Switch case the data type and we have for of them
            switch(data.type) {
              case "text":
                input = this._createTextField();
                break;

              case "numeric":
                input = this._createNumericField(data);
                break;

              case "multiselect":
                input = this._createMultiSelectField(data);
                break;

              case "boolean":
                input = this._createBooleanField(data);
                break;
            }

            // Adding data to the main array so that programatically we can access later
            fieldArray[fieldArrayIndex ++] = this._createDefaultFieldForTabs();
            $(fieldArray[fieldArrayIndex - 1]).find(".plate-setup-tab-name").html(data.name);
            $(this.allDataTabs[tabPointer]).append(fieldArray[fieldArrayIndex - 1]);
            // now we are adding the field which was collected in the switch case.
            $(fieldArray[fieldArrayIndex - 1]).find(".plate-setup-tab-field-container").html(input);

            // Adding checkbox
            var checkImage = $("<img>").attr("src", this.imgSrc + "/do.png").addClass("plate-setup-tab-check-box")
            .data("clicked", true);
            $(fieldArray[fieldArrayIndex - 1]).find(".plate-setup-tab-field-left-side").html(checkImage);
            this._applyCheckboxHandler(checkImage); // Adding handler for change the image when clicked
            fieldArray[fieldArrayIndex - 1].checkbox = checkImage;

            if(data.type == "multiselect") {
              // Adding select2
              $("#" + data.id).select2({
                placeholder: "cool",
                allowClear: true
              });
            } else if(data.type == "numeric") {
              // Adding prevention for non numeric keys, its basic. need to improve.
              $(input).keydown(function(evt) {
                var charCode = (evt.which) ? evt.which : evt.keyCode
                return !(charCode > 31 && (charCode < 48 || charCode > 57));
              });
              // Now add the label which shows unit.
              var unitDropDown = this._addUnitDropDown(data);
              $(fieldArray[fieldArrayIndex - 1]).find(".plate-setup-tab-field-container").append(unitDropDown);

              $("#" + data.id + data.name).select2({

              });

              fieldArray[fieldArrayIndex - 1].unit = unitDropDown;
              // Remember fieldArray has all the nodes from tab -> individual tab -> an Item in the tab -> and Its unit.
              // May be take it as a linked list

            } else if(data.type == "boolean") {
              // Applying select 2 to true/false drop down
              $("#" + data.id + data.name).select2({

              });
            }

          }

          this.allDataTabs[tabPointer]["fields"] = fieldArray;
        } else {
          console.log("unknown format in field initialization");
        }
        tabPointer ++;
      }
    },

    /*
      Poor method just returns an input field.
    */
    _createTextField: function() {

      return this._createElement("<input>").addClass("plate-setup-tab-input");
    },

    /*
      creating a multiselect field. Nothibg serious, this method returns a select box
      which is having all the required fields in the options hash.
    */
    _createMultiSelectField: function(selectData) {

      // we create select field and add options to it later
      var selectField = this._createElement("<select></select>").attr("id", selectData.id)
        .addClass("plate-setup-tab-select-field");
      // Look for all options in the json
      for(options in selectData.options) {
        var optionData = selectData.options[options];
        var optionField = this._createElement("<option></option>").attr("value", optionData.name)
        .html(optionData.name);
        // Adding options here.
        $(selectField).append(optionField);
      }

      return selectField;
    },

    /*
      Numeric field is one which we enter number besides
      it has a unit.
    */
    _createNumericField: function(numericFieldData) {

      var numericField = this._createElement("<input>").addClass("plate-setup-tab-input")
      .attr("placeholder", numericFieldData.placeholder || "");

      return numericField;
    },

    /*
      To have true of false field
    */
    _createBooleanField: function(boolData) {

      var boolField = this._createElement("<select></select>").attr("id", boolData.id + boolData.name)
      .addClass("plate-setup-tab-select-field");
      var trueBool = this._createElement("<option></option>").attr("value", true).html("true");
      var falseBool = this._createElement("<option></option>").attr("value", false).html("false");

      $(boolField).append(trueBool).append(falseBool);

      return boolField;
    },

    /*
      Dynamically making the dropdown and returning it.
      select2 can be applyed only after dropdown has been added jto DOM.
    */
    _addUnitDropDown: function(unitData) {

      if(unitData.units) {

        var unitSelect = this._createElement("<select></select>").attr("id", unitData.id + unitData.name)
        .addClass("plate-setup-tab-label-select-field");
        for(unit in unitData.units) {

          var unitOption = this._createElement("<option></option>").attr("value", unitData.units[unit]).html(unitData.units[unit]);
          $(unitSelect).append(unitOption);
        }

        return unitSelect;
      }
    },

    /*
      We cant implement check box in the default way. So we use images
      and control the behavious , Look at the click handler.
    */
    _applyCheckboxHandler: function(checkBoxImage) {

      var that = this;
      $(checkBoxImage).click(function(evt) {
        if($(this).data("clicked")) {
          $(this).attr("src", that.imgSrc + "/dont.png");
        } else {
          $(this).attr("src", that.imgSrc + "/do.png");
        }

        $(this).data("clicked", !$(this).data("clicked"));
      });
    },

    /*
      This method creates an outline and structure for a default field in the tab at the right side.
      it creates few divs and arrange it so that checkbox, caption and field can be put in them.
    */
    _createDefaultFieldForTabs: function() {

      var wrapperDiv = this._createElement("<div></div>").addClass("plate-setup-tab-default-field");
      var wrapperDivLeftSide = this._createElement("<div></div>").addClass("plate-setup-tab-field-left-side");
      var wrapperDivRightSide = this._createElement("<div></div>").addClass("plate-setup-tab-field-right-side ");
      var nameContainer = this._createElement("<div></div>").addClass("plate-setup-tab-name");
      var fieldContainer = this._createElement("<div></div>").addClass("plate-setup-tab-field-container");

      $(wrapperDivRightSide).append(nameContainer);
      $(wrapperDivRightSide).append(fieldContainer);
      $(wrapperDiv).append(wrapperDivLeftSide);
      $(wrapperDiv).append(wrapperDivRightSide);

      return wrapperDiv;
    }

  });

})(jQuery, fabric);
