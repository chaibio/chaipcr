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

	mathLogic: function(temperature, prev) { //this part is implemented with Pythagorean theorem.
		var rad2deg = 180/Math.PI;
		topper = (157 - (prev * 1.57)) - (157 - (temperature * 1.57));
		padam = 150, lambam = topper;
		widthing = Math.sqrt( (padam * padam) + (lambam * lambam) );
		ratio = lambam/padam;
		var degrees = Math.atan( ratio ) * rad2deg * -1; //atan is used to get the angle of the lines.
		$(this.el).css("width", widthing);
		$(this.el).css("right", 105 + (widthing - 150));
		$(this.el).css("-webkit-transform", "rotate("+degrees+"deg)");
	},

	dragLine: function(dragTemp) {
		this.model.temperature = dragTemp;
		if(_.isUndefined(this.options.previousLine)) { //For the very first step
			fixLeftSide = 25;
		} else {
			fixLeftSide = this.options.previousLine.model.temperature;
		}
		this.mathLogic(dragTemp, fixLeftSide);
		
		if(! _.isUndefined(this.options.nextLine)) { // For the last step
			nextDude = this.options.nextLine;
			nextDude.trigger("moveLineRight", {"leftSide": dragTemp});
		}
	},
	
	render: function(temperature) {
		this.positionLine(temperature);
		return this;
	}
});