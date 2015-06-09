ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayOptionsContent = Backbone.View.extend({

	className: "menu-overlay-options-content",

	template: JST["backbone/templates/app/menu-overlay-options-content"],

	events: {
			"click #delete-exp": "deleteExp"
	},

	initialize: function() {

	},

	deleteExp: function() {
		//alert("Delete");
		this.deleteModel = new ChaiBioTech.app.Views.errorModel({
			message: "Wow"
		});

		$("html").append(this.deleteModel.render().el);
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});
