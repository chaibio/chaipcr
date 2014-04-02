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
		"click #delete-selected": "deleteSelected",
		"click #holding": "addHoldingStage",
		"click #cycling": "addCyclingStage"
	},

	addHoldingStage: function(e) {
		e.preventDefault();
		alert("holding");
	},

	addCyclingStage: function(e) {
		e.preventDefault();
		alert("cycling");
	},

	addAfter: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			target = ChaiBioTech.Data.selectedStep.options.parentStage;
		//$("#innertrack").css("width", ($("#innertrack").width() + 150) + "px");
			this.model.createStep(ChaiBioTech.Data.selectedStep, target);
		} else {
			alert("Plz select a step first");
		}
	},

	addBefore: function(e) {
		e.preventDefault();
		console.log(ChaiBioTech.Data.selectedStep);
	},

	deleteSelected: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.deleteStep(ChaiBioTech.Data.selectedStep);
			ChaiBioTech.Data.selectedStep = null; 
		} else {
			alert("Plz select a step to delete");
		}
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	},

	addStages: function() {
		stages = this.model.get("experiment");
		stages = stages["protocol"]["stages"];
		that = this;
		previous_stage_id = null;
		_.each(stages, function(stage, index) {
			
			stageView = new ChaiBioTech.Views.Design.stages({
				model: stage["stage"], //this points to stage within _.each's context
				stageInfo: stage,
				prev_stage_id: previous_stage_id
			});
			previous_stage_id = stage["stage"]["id"];		
			$("#innertrack").append(stageView.render().el);
			stageView.addSteps(index);
		});
		
	}
});
