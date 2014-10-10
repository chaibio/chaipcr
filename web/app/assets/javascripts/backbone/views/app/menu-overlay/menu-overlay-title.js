ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayTitle = Backbone.View.extend({

	className: "menu-overlay-title",

	template: JST["backbone/templates/app/menu-overlay-title"],

	initialize: function() {
		
	},

	render: function() {
		var data = {
			"name": this.model.get("experiment").name
		}
		$(this.el).html(this.template(data));
		return this;
	}
});
