ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.homePage = Backbone.View.extend({
	
	template: JST["backbone/templates/touchscreen/main"],
	events: {
		"click #goButton": "runExp"
	},

	initialize: function() {
		//alert("i am born");
		console.log(this);
	},

	runExp: function() {
		//alert("bingo");
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});