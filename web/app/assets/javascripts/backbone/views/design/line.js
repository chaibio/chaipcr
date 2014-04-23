ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.line = Backbone.View.extend({

	className: 'line',

	initialize: function() {
		if(! _.isUndefined(this.options.previousLine)) {
			previous = this.options.previousLine;
			previous.options.nextLine = this;
		}

		console.log("Line",this);
	},

	positionLine: function() {
		temperature = parseFloat(this.model.temperature);
		var rad2deg = 180/Math.PI;
		prev = (!_.isUndefined(ChaiBioTech.Data.PreviousTemp)) ? ChaiBioTech.Data.PreviousTemp : 25;
		//prev1 = (!_.isUndefined(this.options.previousLine)) ? this.options.previousLine.temperature : 25;
		//console.log(prev, prev1);
		topper = (157 - (prev * 1.57)) - (157 - (temperature * 1.57));
		padam = 149, lambam = topper;
		widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
		$(this.el).css("width", widthing);
		$(this.el).css("right", 105 + (widthing - 150));
		ChaiBioTech.Data.PreviousTemp = temperature;
		ratio = lambam/padam;
		var degrees = Math.atan( ratio ) * rad2deg * -1;
		$(this.el).css("-webkit-transform", "rotate("+degrees+"deg)");

	},

	dragLine: function(dragTemp) {

		this.model.temperature = dragTemp;
		//console.log(this.model.get("temperature"))
		
		if(_.isUndefined(this.options.previousLine)) {
			fixLeftSide = 25;
		} else {
			fixLeftSide = this.options.previousLine.model.temperature;
		}
		var rad2deg = 180/Math.PI;
		console.log("drag temp", dragTemp, fixLeftSide, this);
		topper = (157 - (fixLeftSide * 1.57)) - (157 - (dragTemp * 1.57));
		padam = 149, lambam = topper;
		widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
		$(this.el).css("width", widthing);
		$(this.el).css("right", 105 + (widthing - 150));
		//ChaiBioTech.Data.PreviousTemp = temperature;
		ratio = lambam/padam;
		var degrees = Math.atan( ratio ) * rad2deg * -1;
		$(this.el).css("-webkit-transform", "rotate("+degrees+"deg)");
	},
	
	render: function(temperature) {
		this.positionLine(temperature);
		return this;
	}
});