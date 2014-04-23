ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.line = Backbone.View.extend({

	className: 'line',

	initialize: function() {
		
	},

	render: function(temperature) {
		var rad2deg = 180/Math.PI;
		prev = (!_.isUndefined(ChaiBioTech.Data.PreviousTemp)) ? ChaiBioTech.Data.PreviousTemp : 25;
		console.log("previous value", prev)
		topper = (157 - (prev * 1.57)) - (157 - (temperature * 1.57));
			//$(this.line.el).css("top", (157 - (25 * 1.57)) +"px");
			padam = 149, lambam = topper;
			widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
			$(this.el).css("width", widthing);
			$(this.el).css("right", 105 + (widthing - 150));
			ChaiBioTech.Data.PreviousTemp = temperature;

			ratio = lambam/padam;
			var degrees = Math.atan( ratio ) * rad2deg * -1;
			$(this.el).css("-webkit-transform", "rotate("+degrees+"deg)");
		return this;
	}
});