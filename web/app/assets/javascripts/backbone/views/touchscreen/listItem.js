ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.listItem = Backbone.View.extend({

	template: JST["backbone/templates/touchscreen/list-item"],

	initialize: function() {
		
	},

	render: function() {
		data = this.model.get("experiment");
		templateData = {
			name: data.name,
			myClass: this.options["myClass"],
			id: data.id
		}
		$(this.el).html(this.template(templateData));
		return this;
	}
});