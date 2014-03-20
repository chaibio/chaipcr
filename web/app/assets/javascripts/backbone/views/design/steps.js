ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.steps = Backbone.View.extend({
	
	className: 'step-run',

	initialize: function() {
		this.tempControlView = new ChaiBioTech.Views.Design.tempControl({
			model: this.model
		});
	},

	render:function() {
		$(this.el).append(this.tempControlView.render().el)
		return this;
	}
});