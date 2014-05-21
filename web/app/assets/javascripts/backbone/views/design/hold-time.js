ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.holdTime = Backbone.View.extend({
	
	template: JST["backbone/templates/design/hold-time"],
	disablePropagationMinutes: false,
	disablePropagationSeconds: false,
	holdTimeInSeconds: 0,
	className: "hold-time",
	events: {
		"click .minutes": "editMinute",
		"click .seconds": "editSeconds"
	},

	editMinute: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		$(".editable-popup").find(".input-mini"). //Injecting attr s to number, editable doen't support number type
		attr("min", 0).
		attr("max", 59);
		//if(! this.disablePropagationMinutes) { // Tells click on the editable shd stay thr itself
			$(".editable-popup").on("click", function(evt) {
				evt.stopPropagation();
			});
			//this.disablePropagationMinutes = true;
		//}
	},

	editSeconds: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		$(".editable-popup").find(".input-mini"). //Injecting attr s to number, editable doen't support number type
		attr("min", 0).
		attr("max", 59);
		//if(! this.disablePropagationSeconds) { // Tells click on the editable shd stay thr itself
			$(".editable-popup").on("click", function(evt) {
				evt.stopPropagation();
			});
			//this.disablePropagationSeconds = true;
		//}
	},

	changeHoldTime: function() {
		console.log(this, this.minutes, this.seconds);
		this.holdTimeInSeconds = (this.minutes * 60) + this.seconds;
		$(this.el).html("");
		this.render();

	},

	initialize: function() {
		this.holdTimeInSeconds = parseInt(this.model["hold_time"]);
		this.minutes = (this.holdTimeInSeconds/60).toFixed();
		this.seconds = this.holdTimeInSeconds%60;
	},

	render: function() {
		holdTimeObject = this;
		timeInSeconds = this.holdTimeInSeconds;
		console.log("Lolax", timeInSeconds);
		minutes = (timeInSeconds >= 60) ? (timeInSeconds / 60).toFixed() : "0";
		seconds = timeInSeconds % 60;
		minutes = (minutes < 10) ? "0"+minutes.toString() : minutes;
		seconds = (seconds < 10) ? "0"+seconds.toString() : seconds;
		time = {
			minutes: minutes,
			seconds: seconds
		}
		$(this.el).html(this.template(time));
		//Two handlers can be combined below but it will take some 
		//complex code to figure out right function call. So this way, less complex
		$(this.el).find(".seconds ").editable({
           type:  'number',
           title: 'Seconds',
           name:  'seconds',
           success:   function(respo, newval) {
           		thisPointer = $(this).data("data-thisObject");//Correcting the reference
           		thisPointer.seconds = parseInt(newval);
           		thisPointer.changeHoldTime();
           }
	    });

	    $(this.el).find(".minutes").editable({
           type:  'number',
           title: 'Minutes',
           name:  'minutes',
           success:   function(respo, newval) {
           		thisPointer = $(this).data("data-thisObject");//Correcting the reference
           		thisPointer.minutes = parseInt(newval);
           		thisPointer.changeHoldTime();
           }
	    });
	    $(this.el).find(".minutes").data("data-thisObject", this);
	    $(this.el).find(".seconds").data("data-thisObject", this);
		return this
	}

});