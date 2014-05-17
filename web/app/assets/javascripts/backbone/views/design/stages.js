ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.stages = Backbone.View.extend({

	template: JST["backbone/templates/design/stage"],
	className: 'stage-run',
	editableAdded: false ,
	events: {
		"click .stage-header": "selectStage",
		"click .stageName" : "changeStageName"
	},

	changeStageName: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		if(! this.editableAdded) {
			thisPointer = this;
			$(this.el).find('.stageName').editable({
	           type:  'text',
	           title: 'Enter new Name',
	           name:  'stagename',
	           success:   function(respo, newval) {
	           		thisPointer.editStageName(newval);
	           }
	        });
			this.editableAdded = true;
			//fires a click so that editable works as normal for a single click ..!
			$(this.el).find('.stageName').click();
		}
	},

	selectStage: function() {
		parentObject = this.options.grandParent.get("experiment");
		if(parentObject["protocol"]["stages"].length == 1) {
			$("#delete-selected").prop("disabled", true);
		} else {
			$("#delete-selected").prop("disabled", false);
		}

		if(!_.isUndefined(ChaiBioTech.Data.selectedStep) && !_.isNull(ChaiBioTech.Data.selectedStep)) {
			ChaiBioTech.Data.selectedStep.trigger("unselectStep");
		}

		if(!_.isUndefined(ChaiBioTech.Data.selectedStage) && !_.isNull(ChaiBioTech.Data.selectedStage)) {

			if(this.cid ===  ChaiBioTech.Data.selectedStage.cid) {
				$(this.el).css("background-color", "white");
				ChaiBioTech.Data.selectedStage = null;
			} else {
				$(this.el).css("background-color","orange");
				oldStepSelected = ChaiBioTech.Data.selectedStage;
				$(oldStepSelected.el).css("background-color", "white");
				ChaiBioTech.Data.selectedStage = this;
			}

		} else {
			$(this.el).css("background-color","orange");
			ChaiBioTech.Data.selectedStage = this;
		}
        console.log(this);
	},

	initialize: function() {

		this.on("unselectStage", function() {
			$(this.el).css("background-color", "white");
			ChaiBioTech.Data.selectedStage = null;
		});

		_.bindAll(this, "addSteps", "render", "editStageName");
	},

	editStageName: function(newName) {
		this.options.grandParent.changeStageName(newName, this.model.id, this.model["stage_type"]); // Points to the model
	},

	render:function() {

		$(this.el).html(this.template(this.options["stageInfo"]["stage"]));
		if(this.model.stage_type == "cycling") {
			cyclingOptions = new ChaiBioTech.Views.Design.cyclingStageOptions({
				model: this.model,
				grandParent: thisObject.options.grandParent
			});
			console.log(cyclingOptions.render().el)
			$(this.el).find(".stage-header").append(cyclingOptions.render().el);
		}
		return this;
	},

	addSteps: function(thisStage, stageNumber) {

		thisObject = this;
		allSteps = this.options["stageInfo"]["stage"];
		allSteps = allSteps["steps"];
		previous_step = null;
		previous_id = null;
		steps = [];
		numberOfSteps = allSteps.length - 1;
		$(thisObject.el).css("width", ((numberOfSteps + 1) * ChaiBioTech.Constants.stepWidth) + 2 +"px");
		currentWidth = $("#innertrack").width();
		$("#innertrack").css("width", (currentWidth + ((numberOfSteps + 1) * ChaiBioTech.Constants.stepWidth) + 2 +"px"));
		_.each(allSteps, function(step, index) {
			stepView = new ChaiBioTech.Views.Design.steps({
				model: step["step"],
				stepInfo: step,
				parentStage: thisObject,
				prev_id:  previous_id,
				grandParent: thisObject.options.grandParent
			});

			if(! _.isNull(previous_step)) {
				previous_step.options.next_id = step["step"]["id"];
			}
			previous_step = stepView;
			previous_id = step["step"]["id"];
			if(numberOfSteps != index) {
				$(stepView.el).addClass("stepRightSide")
			}
			$(thisObject.el).find(".step-holder").append(stepView.render().el);
			steps.push(stepView);
		});
		this.steps = steps;
	}
});
