ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.stages = Backbone.View.extend({
	
	template: JST["backbone/templates/design/stage"],
	className: 'stage-run',

	initialize: function() {
		console.log("this is optns", this.options)
	},

	render:function() {
		$(this.el).html(this.template(this.options["stageInfo"]["stage"]));
		return this;
	},

	addSteps: function(stageNumber) {

		that = this;
		allSteps = this.options["stageInfo"]["stage"];
		allSteps = allSteps["steps"];
		
		_.each(allSteps, function(step, index) {

			stepView = new ChaiBioTech.Views.Design.steps({
				model: step["step"],
				stepInfo: step,
				parentStage: that
			});
			//that.dummy = step;
			currentWidth = $(that.el).width();
			$(that.el).css("width", currentWidth + (index * 150)+"px");
			$(that.el).find(".step-holder").append(stepView.render().el);
		})
	},

	addStep: function(pole, place) {
		stepView = new ChaiBioTech.Views.Design.steps({
			model: that.model,
			stepInfo: place,
			parentStage: this
		});
		currentWidth = $(this.el).width();
		$(this.el).css("width", (currentWidth + 150) +"px");
		$(pole.el).after(stepView.render().el);
	}
});