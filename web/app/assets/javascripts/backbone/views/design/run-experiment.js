ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],

	initialize: function() {
		
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	},

	addStages: function() {
		stages = this.model.get("experiment");
		stages = stages["protocol"]["stages"];
		that = this;
		
		_.each(stages, function(stage, index) {
			
			stageView = new ChaiBioTech.Views.Design.stages({
				model: that.model, //this points to stage within _.each's context
				stageInfo: stage
			});

			$("#innertrack").append(stageView.render().el);
			stageView.addSteps(index);
		});
		
	}
});
