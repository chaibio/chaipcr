ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayMenuItemSpecial = Backbone.View.extend({

	className: "menu-overlay-menu-item-special",

	template: JST["backbone/templates/app/menu-overlay/menu-overlay-menu-item-special"],

	events: {
		"mouseenter .menu-text": "mouseCame",
		"mouseleave .menu-text": "mouseGone"
	},

	initialize: function() {
		this.myName = this.options.menuData;
	},

	render: function() {
		var data = {
			"menuItem": this.myName.menuItem,
			"id": this.model.get("experiment").id
		};
		
		$(this.el).html(this.template(data));
		return this;
	},

	mouseCame: function() {
		$(this.el).find(".menu-text").css("font-weight", "bold");
	},

	mouseGone: function() {
		$(this.el).find(".menu-text").css("font-weight", "normal");
	}
})
