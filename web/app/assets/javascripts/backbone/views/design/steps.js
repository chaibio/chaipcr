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
		
		var rad2deg = 180/Math.PI;
		if(_.isUndefined(ChaiBioTech.Data.PreviousTemp)) {
			
			topper = (157 - (25 * 1.57)) - (157 - (temperature * 1.57));
			$(this.line.el).css("top", (157 - (25 * 1.57)) +"px");
			padam = 149, lambam = topper;
			widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
			$(this.line.el).css("width", widthing);

			ChaiBioTech.Data.PreviousTemp = 157 - (temperature * 1.57);

			ratio = lambam/padam;
			var degrees = Math.atan( ratio ) * rad2deg * -1;
			$(this.line.el).css("-webkit-transform", "rotate("+degrees+"deg)");
			
		} else {
			$(this.line.el).css("top", ChaiBioTech.Data.PreviousTemp);
			ChaiBioTech.Data.PreviousTemp = 157 - (temperature * 1.57);
		}
		return this;
	}
});