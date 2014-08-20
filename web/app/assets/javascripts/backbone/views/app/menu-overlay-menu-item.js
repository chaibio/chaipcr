ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayMenuItem = Backbone.View.extend({

	className: "menu-overlay-menu-item",

	template: JST["backbone/templates/app/menu-overlay-menu-item"],

	events: {
		"mouseenter .menu-text": "mouseCame",
		"mouseleave .menu-text": "mouseGone"
	},

	initialize: function() {
		this.myNmane = this.options.menuData;
	},

	render: function() {
		$(this.el).html(this.template(this.myNmane))
		return this;
	},

	mouseCame: function() {
		$(this.el).find(".menu-text").css("font-weight", "bold");
	},

	mouseGone: function() {
		$(this.el).find(".menu-text").css("font-weight", "normal");
	}
});
