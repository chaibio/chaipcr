ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.steps = Backbone.View.extend({
	
	className: 'step-run',

	events: {
		"click": "selectThisStep"
	},

	selectThisStep: function() {

		if((_.isUndefined(this.options.next_id)) && (_.isNull(this.options.prev_id) )) {
			daddyStage = this.options.parentStage;
			if( _.isUndefined(daddyStage.options.next_stage_id) && _.isNull(daddyStage.options.prev_stage_id) ){
				$("#delete-selected").prop("disabled", true);
			} else {
				$("#delete-selected").prop("disabled", false);
			}
		} else {
			$("#delete-selected").prop("disabled", false);
		}

		if(!_.isUndefined(ChaiBioTech.Data.selectedStage) && !_.isNull(ChaiBioTech.Data.selectedStage)) {
			ChaiBioTech.Data.selectedStage.trigger("unselectStage");
		}
		
		if(!_.isUndefined(ChaiBioTech.Data.selectedStep) && !_.isNull(ChaiBioTech.Data.selectedStep)) {

			if(this.cid ===  ChaiBioTech.Data.selectedStep.cid) {
				$(this.el).css("background-color", "yellow");
				ChaiBioTech.Data.selectedStep = null;
			} else {
				$(this.el).css("background-color","orange");
				oldStepSelected = ChaiBioTech.Data.selectedStep;
				$(oldStepSelected.el).css("background-color", "yellow");
				ChaiBioTech.Data.selectedStep = this;
			}

		} else {
			$(this.el).css("background-color","orange");
			ChaiBioTech.Data.selectedStep = this;
		}
		//console.log(ChaiBioTech.Data.selectedStep);
	},

	initialize: function() {
		this.tempControlView = new ChaiBioTech.Views.touchScreen.tempControl({
			model: this.model,
			parentStep: this,
			grandParent: thisObject.options.grandParent
		});
		

		this.on("unselectStep", function() {
			$(this.el).css("background-color", "yellow");
			ChaiBioTech.Data.selectedStep = null;
		});

		this.on("changeTemperature", function(tempData) {
			this.options.grandParent.changeTemperature(tempData, this.model);
		});

	},

	render:function() {
		$(this.el).append(this.tempControlView.render().el);
		temperature = this.options["stepInfo"]["step"]["temperature"]
		$(this.tempControlView.el).css("top", ChaiBioTech.Constants.stepHeight - (temperature * ChaiBioTech.Constants.stepUnitMovement) +"px");
		return this;
	}
});