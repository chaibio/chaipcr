ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.listItem = Backbone.View.extend({

	template: JST["backbone/templates/touchscreen/list-item"],
	initialize: function() {
		
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});