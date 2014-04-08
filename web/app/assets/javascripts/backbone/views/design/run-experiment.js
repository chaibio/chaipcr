ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],

	initialize: function() {
		that = this;
		_.bindAll(this, "addStages")
		this.model.on("change:experiment", function() {
			$("#innertrack").html("");
			$("#innertrack").css("width", "1000px");
			window.router.runView.addStages();
		})
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
		} else {
			this.model.createStage("holding", ChaiBioTech.Data.lastStage);
		}
		
	},

	addCyclingStage: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("cycling", ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null;
		} else {
			this.model.createStage("cycling", ChaiBioTech.Data.lastStage);
		}
	},

	addMeltCurve: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("meltcurve", ChaiBioTech.Data.selectedStage);
			ChaiBioTech.Data.selectedStage = null;
		} else {
			this.model.createStage("meltcurve", ChaiBioTech.Data.lastStage);
		}
	},

	addAfter: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.createStep(ChaiBioTech.Data.selectedStep, "after");
		} else {
			alert("Plz select a step");
		}
	},

	addBefore: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.createStep(ChaiBioTech.Data.selectedStep, "before");
		} else {
			alert("Plz select a step");
		}
	},

	deleteSelected: function(e) {
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
		that = this;
		previous_stage_id = null;
		_.each(stages, function(stage, index) {
			
			stageView = new ChaiBioTech.Views.Design.stages({
				model: stage["stage"], //this points to stage within _.each's context
				stageInfo: stage,
				prev_stage_id: previous_stage_id
			});
			previous_stage_id = stage["stage"]["id"];
			ChaiBioTech.Data.lastStage = stageView;	
			$("#innertrack").append(stageView.render().el);
			stageView.addSteps(index);
		});
		
	}
});
