ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.cyclingStageOptions = Backbone.View.extend({
	
	template: JST["backbone/templates/design/cyclingStageOptions"],

	initialize: function() {
		//alert("i am born ");
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});