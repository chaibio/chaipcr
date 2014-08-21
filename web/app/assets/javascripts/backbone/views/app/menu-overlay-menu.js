ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayMenu = Backbone.View.extend({

	className: "menu-overlay-menu",

	menuItems: [
				"EXPERIMENT PROPERTIES", 
				"EDIT PROTOCOL", 
				"PLATE SETUP", 
				"RUN EXPERIMENT", 
				"RESULTS 1",
				"RESULTS 2", 
				"RESULTS 3"
				],

	template: JST["backbone/templates/app/menu-overlay-menu"],

	NoOfSpecialDude: 3,

	initialize: function() {
		console.log(this.menuItems);
	},

	render: function() {
		var length = this.menuItems.length, tempCarrier = {};

		for (var i = 0; i < length; i++) {
	
			tempCarrier = {
				"menuItem": this.menuItems[i]
			}

			if(i === this.NoOfSpecialDude) {
				// Big menu item
				var thisMenuItem = new ChaiBioTech.app.Views.menuOverlayMenuItemSpecial({
					"menuData": tempCarrier
				});

			} else {
				// Normal menu item
				var thisMenuItem = new ChaiBioTech.app.Views.menuOverlayMenuItem({
					"menuData": tempCarrier
				});
			}

			$(this.el).append(thisMenuItem.render().el);

			if(i > this.NoOfSpecialDude) {
				// after we post the big menu item, We should leave blue tail to rest of the menu items. 
				$(thisMenuItem.el).find(".tail").css("background-color", "#00aeef");
			}
		}

		return this;
	},


});