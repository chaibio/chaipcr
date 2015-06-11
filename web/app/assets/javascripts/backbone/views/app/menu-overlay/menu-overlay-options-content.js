ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverlayOptionsContent = Backbone.View.extend({

	className: "menu-overlay-options-content",

	template: JST["backbone/templates/app/menu-overlay-options-content"],

	events: {

			"click #delete-exp": "deleteExp",
	},

	initialize: function() {

		var that = this;

		this.on("okay", function() {
			console.log("okay");
			that.okay();
		});

		this.on("cancel", function() {
			console.log("cancel");
			that.cancel();
		});
	},

	okay: function() {
		// when we click okay button
	},

	cancel: function() {
		// When we click cancel button
	},

	deleteExp: function() {

		var data = {
			messageTitle: "DESCRIPTION OF ERROR",
			message: "Are you sure you want to delete ?"
		}

		this.deleteModel = new ChaiBioTech.app.Views.errorModel({
			message: data,
			parent: this
		});

		$("#container").append(this.deleteModel.render().el);
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});
