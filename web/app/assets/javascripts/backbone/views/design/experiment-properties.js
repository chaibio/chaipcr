ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.experiment_properties = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-properties"],
	
	events: {
		"click #experiment-property-add": "addExperiment"
	},

	initialize: function() {
		_.bindAll(this, "SavedHandler")
		this.model.view = this;	
		this.model.on("Saved", this.SavedHandler);
		
	},

	SavedHandler: function() {
		$(this.el).find(".shadow").fadeIn('fast');
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	},

	addExperiment: function() {
		var newExperiment = this.model.get("experiment");
		newExperiment.name = $("#experiment-name").val();
		this.model.set({experiment: newExperiment});
		(newExperiment["id"] ) ? this.model.saveData("update") : this.model.saveData("save");
		console.log(this.model)
	}
});