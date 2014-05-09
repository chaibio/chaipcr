ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],
	expId: "",

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
			this.model.createStage("holding", ChaiBioTech.Data.selectedStage, this.expId);
			ChaiBioTech.Data.selectedStage = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)){
			ChaiBioTech.Data.selectedStage = ChaiBioTech.Data.selectedStep.options.parentStage;
			this.model.createStage("holding", ChaiBioTech.Data.selectedStage, this.expId);
		} else {
			this.model.createStage("holding", ChaiBioTech.Data.lastStage, this.expId);
		}
		
			ChaiBioTech.Data.selectedStage = null;
	},

	addCyclingStage: function(e) {
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("cycling", ChaiBioTech.Data.selectedStage, this.expId);
			ChaiBioTech.Data.selectedStage = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data
		e.preventDefault();.selectedStep)){
			ChaiBioTech.Data.selectedStage = ChaiBioTech.Data.selectedStep.options.parentStage;
			this.model.createStage("cycling", ChaiBioTech.Data.selectedStep.options.parentStage, this.expId);
			ChaiBioTech.Data.selectedStep = null;
		} else {
			this.model.createStage("cycling", ChaiBioTech.Data.lastStage, this.expId);
		}
	},

	addMeltCurve: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.createStage("meltcurve", ChaiBioTech.Data.selectedStage, this.expId);
			ChaiBioTech.Data.selectedStage = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)){
			ChaiBioTech.Data.selectedStage = ChaiBioTech.Data.selectedStep.options.parentStage;
			this.model.createStage("meltcurve", ChaiBioTech.Data.selectedStep.options.parentStage, this.expId);
			ChaiBioTech.Data.selectedStep = null;
		} else {
			this.model.createStage("meltcurve", ChaiBioTech.Data.lastStage, this.expId);
		}
	},

	addAfter: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.createStep(ChaiBioTech.Data.selectedStep, "after", this.expId);
			ChaiBioTech.Data.selectedStep = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			lastDude = ChaiBioTech.Data.selectedStage.steps.length - 1;
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage.steps[lastDude];
			this.model.createStep(ChaiBioTech.Data.selectedStep, "after", this.expId);
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage = null;
		} else {
			alert("Plz select a step or a stage");
		}
	},

	addBefore: function(e) {
		e.preventDefault();
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.createStep(ChaiBioTech.Data.selectedStep, "before", this.expId);
			ChaiBioTech.Data.selectedStep = null;
		} else if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage.steps[0];
			this.model.createStep(ChaiBioTech.Data.selectedStep, "before", this.expId);
			ChaiBioTech.Data.selectedStep = ChaiBioTech.Data.selectedStage = null;
		} else {
			alert("Plz select a step or stage");
		}
	},

	deleteSelected: function(e) {
		e.preventDefault();
		console.log(ChaiBioTech.Data.selectedStep)
		if(!_.isNull(ChaiBioTech.Data.selectedStep) && !_.isUndefined(ChaiBioTech.Data.selectedStep)) {
			this.model.deleteStep(ChaiBioTech.Data.selectedStep, this.expId);
			ChaiBioTech.Data.selectedStep = null; 
		} else if(!_.isNull(ChaiBioTech.Data.selectedStage) && !_.isUndefined(ChaiBioTech.Data.selectedStage)) {
			this.model.deleteStage(ChaiBioTech.Data.selectedStage, this.expId);
			ChaiBioTech.Data.selectedStage = null; 
		} else {
			alert("Plz select a step or stage");
		}
	},

	initialize: function() {
		thatObject = this;
		this.model.getLatestModel(this.options.id);
		this.model.on("change:experiment", function() {
			$("#innertrack").html("");
			$("#innertrack").css("width", "1000px");
			console.log("vroom",thatObject);
			thatObject.expId = thatObject.model.get("experiment")["id"];
			thatObject.addStages();
		});
	},

	render: function() {
		$(this.el).html(this.template());
		$(this.el).find("#run-experiment").
		removeClass("col-md-10").
		addClass("jumbotron");
		return this;
	},

	addStages: function() {
		stages = this.model.get("experiment");
		stages = stages["protocol"]["stages"];
		thatObject = this;
		previous_stage_id = null;
		previous_object = null;
		numberOfStages = stages.length - 1;
		_.each(stages, function(stage, index) {
			
			stageView = new ChaiBioTech.Views.touchScreen.stages({
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
			if(numberOfStages == index) {
				$("#innertrack").append($("<DIV>").addClass("boundaryDiv"));
			}
			stageView.addSteps(stageView, index);
		});
		
	}

});