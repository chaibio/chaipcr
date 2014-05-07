ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.runExperiment = Backbone.View.extend({

	template: JST["backbone/templates/design/experiment-run"],
	initialize: function() {
		thatObject = this;
		//console.log("dd", this)
		this.model.getLatestModel(this.options.id);
		this.model.on("change:experiment", function() {
			console.log("vroom",thatObject);
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
			if(numberOfStages == index) {
				$("#innertrack").append($("<DIV>").addClass("boundaryDiv"));
			}
			stageView.addSteps(stageView, index);
		});
		
	}

});