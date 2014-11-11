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

	NoOfSpecialDude: 3,

	initialize: function() {

		var id = this.model.get("experiment").id;
		this.menuLinks = [
				"#",
				"#/edit-stage-step/" + id,
				"#/plate-setup/" + id,
				"#",
				"#",
				"#",
				"#"
			]
	},

	render: function() {

		var length = this.menuItems.length, tempCarrier = {};

		for (var i = 0; i < length; i++) {

			tempCarrier = {
				"menuItem": this.menuItems[i],
				"link": this.menuLinks[i]
			};

			if(i === this.NoOfSpecialDude) {
				// Big menu item
				var thisMenuItem = new ChaiBioTech.app.Views.menuOverlayMenuItemSpecial({
					model: this.model,
					"menuData": tempCarrier
				});

			} else {
				// Normal menu item
				var thisMenuItem = new ChaiBioTech.app.Views.menuOverlayMenuItem({
					model: this.model,
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
