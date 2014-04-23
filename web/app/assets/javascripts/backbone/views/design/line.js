ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.line = Backbone.View.extend({

	className: 'line',

	initialize: function() {
		if(! _.isUndefined(this.options.previousLine)) {
			previous = this.options.previousLine;
			previous.options.nextLine = this;
		}
	},

	positionLine: function() {
		temperature = parseFloat(this.model.temperature);
		prev = (!_.isUndefined(ChaiBioTech.Data.PreviousTemp)) ? ChaiBioTech.Data.PreviousTemp : 25;
		this.mathLogic(temperature, prev);
	},

	mathLogic: function(temperature, prev) {
		var rad2deg = 180/Math.PI;
		topper = (157 - (prev * 1.57)) - (157 - (temperature * 1.57));
		padam = 149, lambam = topper;
		widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
		ChaiBioTech.Data.PreviousTemp = temperature;
		ratio = lambam/padam;
		var degrees = Math.atan( ratio ) * rad2deg * -1;
		$(this.el).css("width", widthing);
		$(this.el).css("right", 105 + (widthing - 150));
		$(this.el).css("-webkit-transform", "rotate("+degrees+"deg)");
	},

	dragLine: function(dragTemp) {
		this.model.temperature = dragTemp;
		if(_.isUndefined(this.options.previousLine)) {
			fixLeftSide = 25;
		} else {
			fixLeftSide = this.options.previousLine.model.temperature;
		}
		this.mathLogic(dragTemp, fixLeftSide);
		this.dragNextLine();
	},

	dragNextLine: function() {

	},
	
	render: function(temperature) {
		this.positionLine(temperature);
		return this;
	}
});