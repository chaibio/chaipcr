ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.line = Backbone.View.extend({

	className: 'line',

	initialize: function() {
		if(! _.isUndefined(this.options.previousLine)) {
			previous = this.options.previousLine;
			previous.options.nextLine = this;
		}

		this.on("moveLineRight", function(newData) {
			this.mathLogic(this.model.temperature, newData.leftSide)
		});

		this.on("moveThisLine", function(newTempData) {
			this.dragLine(newTempData.toThisTemp)
		});
	},

	positionLine: function() {
		temperature = parseFloat(this.model.temperature);
		prev = (! _.isUndefined(this.options.previousLine)) ? this.options.previousLine.model.temperature : 25;
		this.mathLogic(temperature, prev);
	},

	mathLogic: function(temperature, prev) { //this part is implemented with Pythagorean theorem or law of cosines.
		lambam =  (temperature * ChaiBioTech.Constants.stepUnitMovement) - (prev * ChaiBioTech.Constants.stepUnitMovement);
		padam = ChaiBioTech.Constants.stepWidth - ChaiBioTech.Constants.tempBarWidth;
		widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
		ratio = lambam/padam;
		var degrees = Math.atan( ratio ) * ChaiBioTech.Constants.rad2deg * -1; //atan is used to get the angle of the lines.
		$(this.el).css("width", widthing)
		.css("right", widthing - 1)
		.css("-webkit-transform", "rotate("+degrees+"deg)");
	},

	dragLine: function(dragTemp) {
		this.model.temperature = dragTemp;
		if(_.isUndefined(this.options.previousLine)) { //For the very first step.
			fixLeftSide = ChaiBioTech.Constants.beginningTemp;
		} else {
			fixLeftSide = this.options.previousLine.model.temperature;
		}
		this.mathLogic(dragTemp, fixLeftSide);
		
		if(! _.isUndefined(this.options.nextLine)) { // excluding last step.
			nextDude = this.options.nextLine;
			nextDude.trigger("moveLineRight", {"leftSide": dragTemp});
		}
	},
	
	render: function(temperature) {
		this.positionLine(temperature);
		return this;
	}
});