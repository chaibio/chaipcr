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
		stages = this.model.get("experiment")["protocol"]["stages"]; console.log(stages);
		_.each(stages, function(stage, index) {
			console.log(stage);
		});
	}

});