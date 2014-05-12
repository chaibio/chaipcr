ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.cyclingStageOptions = Backbone.View.extend({
	
	template: JST["backbone/templates/design/cyclingStageOptions"],
	optionTemplate: JST["backbone/templates/design/options"],
	events: {
		"click #cycleNumber": "cycleNumber",
		"click #autoDelta": "autoDelta",
		"click #startingCycle": "startingCycle",
		"change #cycleNumber": "changedCycle",
		"change #startingCycle": "changeStartingCycle",
	},

	cycleNumber: function(evt) {
		evt.stopPropagation();
	},

	autoDelta: function(evt) {
		evt.stopPropagation();
	},

	startingCycle: function(evt) {
		evt.stopPropagation();
	},

	changedCycle: function() {
		alert("changed")
	},

	changeStartingCycle: function() {
		alert("again changed")
	},

	initialize: function() {
		//alert("i am born ");
	},

	render: function() {
		$(this.el).html(this.template());
		keeper = "";
		for(var i = 0; i<40; i++) {
			keeper = this.optionTemplate({"value": i + 1}) + keeper;
		}
		$(this.el).find("#cycleNumber").html(keeper);
		$(this.el).find("#startingCycle").html(keeper);
		return this;
	}
});