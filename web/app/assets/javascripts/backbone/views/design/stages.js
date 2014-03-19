ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.stages = Backbone.View.extend({
	
	template: JST["backbone/templates/design/stage"],
	className: 'stage-run',
	
	initialize: function() {

	},

	render:function() {
		$(this.el).html(this.template());
		return this;
	}
});