ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.experiment_properties = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-properties"],
	
	events: {
		"click #experiment-property-add": "addExperiment"
	},

	initialize: function() {
		console.log(this.model);
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	},

	addExperiment: function() {
		this.model.saveData();
	}
});