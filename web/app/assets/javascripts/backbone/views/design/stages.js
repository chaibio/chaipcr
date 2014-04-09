ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.stages = Backbone.View.extend({
	
	template: JST["backbone/templates/design/stage"],
	className: 'stage-run',

	events: {
		"click .stage-header": "selectStage"
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
	},

	render:function() {
		$(this.el).html(this.template(this.options["stageInfo"]["stage"]));
		return this;
	},

	addSteps: function(stageNumber) {

		thisObject = this;
		allSteps = this.options["stageInfo"]["stage"];
		allSteps = allSteps["steps"];
		previous_step = null;
		previous_id = null;
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
			
			currentWidth = $(thisObject.el).width();
			$(thisObject.el).css("width", ((index + 1) * 150)+"px");
			currentWidth = $("#innertrack").width();
			$("#innertrack").css("width", (currentWidth + 151) +"px");
			$(thisObject.el).find(".step-holder").append(stepView.render().el);
		})
	},

	//This method could be used if we want to add steps manually , but it comes along with problem of keep tracking diffrence
	//in stage content..!
	addStep: function(pole, place) {
		stepView = new ChaiBioTech.Views.Design.steps({
			model: that.model,
			stepInfo: place,
			parentStage: this
		});
		currentWidth = $(this.el).width();
		console.log("shd be changing", this.model);
		$(this.el).css("width", (currentWidth + 150) +"px");
		currentWidth = $("#innertrack").width();
		$("#innertrack").css("width", (currentWidth+ 151) +"px");
		$(pole.el).after(stepView.render().el);
	}
});