ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],

	initialize: function() {
		thisObject = this;
		_.bindAll(this, "addStages")
		this.model.on("change:experiment", function() {
			$("#innertrack").html("");
			$("#innertrack").css("width", "1000px");
			window.router.runView.addStages();
		});
	},

	events: {
		"click #step-before": "addBefore",
		"click #step-after": "addAfter",
		"click #delete-selected": "deleteSelected",
		"click #holding": "addHoldingStage",
		"click #cycling": "addCyclingStage",
		"click #melt-curve": "addMeltCurve"
	},

	addHoldingStage: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("holding", ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)){
			ChaiBioTech.Data.selectedStage = ChaiBioTech.Data.selectedStep.options.parentStage;
			this.model.createStage("holding", ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null;
		} else {
			this.model.createStage("holding", ChaiBioTech.Data.lastStage);
		}
		
	},

	addCyclingStage: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("cycling", ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)){
			ChaiBioTech.Data.selectedStage = ChaiBioTech.Data.selectedStep.options.parentStage;
			this.model.createStage("cycling", ChaiBioTech.Data.selectedStep.options.parentStage);
			ChaiBioTech.Data.selectedStep = null;
		} else {
			this.model.createStage("cycling", ChaiBioTech.Data.lastStage);
		}
	},

	addMeltCurve: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("meltcurve", ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)){
			ChaiBioTech.Data.selectedStage = ChaiBioTech.Data.selectedStep.options.parentStage;
			this.model.createStage("meltcurve", ChaiBioTech.Data.selectedStep.options.parentStage);
			ChaiBioTech.Data.selectedStep = null;
		} else {
			this.model.createStage("meltcurve", ChaiBioTech.Data.lastStage);
		}
	},

	addAfter: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.createStep(ChaiBioTech.Data.selectedStep, "after");
			ChaiBioTech.Data.selectedStep = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			lastDude = ChaiBioTech.Data.selectedStage.steps.length - 1;
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage.steps[lastDude];
			this.model.createStep(ChaiBioTech.Data.selectedStep, "after");
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage = null;
		} else {
			alert("Plz select a step or a stage");
		}
	},

	addBefore: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.createStep(ChaiBioTech.Data.selectedStep, "before");
			ChaiBioTech.Data.selectedStep = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage.steps[0];
			this.model.createStep(ChaiBioTech.Data.selectedStep, "before");
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage = null;
		} else {
			alert("Plz select a step or stage");
		}
	},

	deleteSelected: function(e) {
		// write code to disable delete thr is only one stage left
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.deleteStep(ChaiBioTech.Data.selectedStep);
			ChaiBioTech.Data.selectedStep = null; 
		} else if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.deleteStage(ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null; 
		} else {
			alert("Plz select a step or stage");
		}
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	},

	addStages: function() {
		stages = this.model.get("experiment");
		stages = stages["protocol"]["stages"];
		thatObject = this;
		previous_stage_id = null;
		previous_object = null;
		_.each(stages, function(stage, index) {
			
			stageView = new ChaiBioTech.Views.Design.stages({
				model: stage["stage"], //this points to stage within _.each's context
				stageInfo: stage,
				prev_stage_id: previous_stage_id,
				grandParent: thatObject.model
			});
			if(!_.isNull(previous_object)) {
				previous_object.options.next_stage_id = stage["stage"]["id"];
			}
			previous_object = stageView;
			previous_stage_id = stage["stage"]["id"];
			ChaiBioTech.Data.lastStage = stageView;	
			$("#innertrack").append(stageView.render().el);
			stageView.addSteps(stageView, index);
		});
		
	}
});
