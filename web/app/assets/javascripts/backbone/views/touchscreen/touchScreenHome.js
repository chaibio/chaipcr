ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.homePage = Backbone.View.extend({
	
	template: JST["backbone/templates/touchscreen/main"],

	initialize: function(){
		//alert("i am born");
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});