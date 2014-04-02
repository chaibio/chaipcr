ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],

	initialize: function() {
		that = this;
		_.bindAll(this, "addStages")
		this.model.on("change:experiment", function() {
			$("#innertrack").html("");
			$("#innertrack").css("width", "1000px");
			//console.log(this, that);
			window.router.runView.addStages();
		})
	},

	events: {
		"click #step-before": "addBefore",
		"click #step-after": "addAfter",
		"click #delete-selected": "deleteSelected"
	},

	addAfter: function(e) {
		e.preventDefault();
		target = ChaiBioTech.Data.selectedStep.options.parentStage;
		//$("#innertrack").css("width", ($("#innertrack").width() + 150) + "px");
		this.model.createStep(ChaiBioTech.Data.selectedStep, target);
	},

	addBefore: function(e) {
		e.preventDefault();
		console.log(ChaiBioTech.Data.selectedStep);
	},

	deleteSelected: function(e) {
		e.preventDefault();
		console.log(ChaiBioTech.Data.selectedStep);
		this.model.deleteStep(ChaiBioTech.Data.selectedStep);
		//ChaiBioTech.Data.selectedStep.remove();
		ChaiBioTech.Data.selectedStep = null; 

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
