ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],

	initialize: function() {
		
	},

	events: {
		"click #step-before": "addBefore",
		"click #step-after": "addAfter"
	},

	addAfter: function(e) {
		e.preventDefault();
		//console.log(ChaiBioTech.Data.selectedStep);
		target = ChaiBioTech.Data.selectedStep.options.parentStage;
		$("#innertrack").css("width", ($("#innertrack").width() + 150) + "px");
		//target.addStep(ChaiBioTech.Data.selectedStep);
		//console.log(this.model);
		this.model.createStep(ChaiBioTech.Data.selectedStep, target);
		//make a new step and send it to target
	},

	addBefore: function(e) {
		//alert("add after");
		e.preventDefault();
		console.log(ChaiBioTech.Data.selectedStep);
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
				model: stage["stage"], //this points to stage within _.each's context
				stageInfo: stage
			});

			$("#innertrack").append(stageView.render().el);
			stageView.addSteps(index);
		});
		
	}
});
