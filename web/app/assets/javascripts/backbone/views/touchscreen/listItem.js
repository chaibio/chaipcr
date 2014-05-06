ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.listItem = Backbone.View.extend({

	template: JST["backbone/templates/touchscreen/list-item"],
	events: {
		"click": "clickHandler"
	},

	clickHandler: function(e) {
		e.preventDefault();
		alert("bingo");
	},

	initialize: function() {
		console.log("Jossie", this);
	},

	render: function() {
		data = this.model["attributes"];
		templateData = {
			name: data.experiment["name"],
			myClass: this.options["myClass"]
		}
		$(this.el).html(this.template(templateData));
		return this;
	}
});