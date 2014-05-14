ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.cyclingStageOptions = Backbone.View.extend({
	numCycles: 0,
	template: JST["backbone/templates/design/cyclingStageOptions"],
	optionTemplate: JST["backbone/templates/design/options"],
	events: {
		"click .save-cycle": "saveCycle",
		"click .form-control": "stopPropagation"
	},

	saveCycle: function(evt) {
		evt.stopPropagation();
		value = this.numCycles = parseInt($(this.el).find(".form-control").val());
		//true if value is a number and within range
		if(! _.isNaN(value) && (value > 0 && value < 1000 )) {
			$(this.el).find(".noof-cycle-warning").hide();
			$(this.el).find(".noof-cycle-success").show();
			this.options.grandParent.changeStageCycle(value, this.model.id, this.model["stage_type"]); 
		} else {
			$(this.el).find(".noof-cycle-warning").show();
			$(this.el).find(".noof-cycle-success").hide();
		}
	},

	stopPropagation: function(evt) {
		evt.stopPropagation();
	},

	initialize: function() {
		this.numCycles = parseInt(this.model["num_cycles"]);
	},

	render: function() {
		cycleConfig = {
			cycleNo: this.numCycles
		}
		$(this.el).html(this.template(cycleConfig));
		keeper = "";
		for(var i = 0; i<40; i++) {
			keeper = this.optionTemplate({"value": i + 1}) + keeper;
		}
		return this;
	}
});
