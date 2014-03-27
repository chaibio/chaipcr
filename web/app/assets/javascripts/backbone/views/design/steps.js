ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.steps = Backbone.View.extend({
	
	className: 'step-run',

	events: {
		"click": "test"
	},

	test: function() {
		//alert("sfdsd");
	},

	initialize: function() {
		//console.log("step", this.options["stepInfo"])
		this.tempControlView = new ChaiBioTech.Views.Design.tempControl({
			model: this.model,
			stepData: this.options["stepInfo"]
		});

		this.line = new ChaiBioTech.Views.Design.line({
			model: this.model
		});
	},

	render:function() {
		$(this.el).append(this.tempControlView.render().el);
		temperature = this.options["stepInfo"]["step"]["temperature"]

		$(this.tempControlView.el).css("top", 157 - (temperature * 1.57) +"px");
		$(this.el).append(this.line.render().el)
		return this;
	}
});