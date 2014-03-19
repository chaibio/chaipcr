ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],

	initialize: function() {
		//alert("initilaized");
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	},

	addStages: function() {
		stages = this.model.get("experiment");
		
		stages = stages["protocol"]["stages"];

		_.each(stages, function(stage) {
			//Goes to #track/
			console.log( stage , "Jossie");
			stageView = new ChaiBioTech.Views.Design.stages();
			$("#track").append(stageView.render().el);
		});
		
	}
});
