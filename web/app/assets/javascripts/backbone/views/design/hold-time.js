ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.holdTime = Backbone.View.extend({
	
	template: JST["backbone/templates/design/hold-time"],
	disablePropagationMinutes: false,
	disablePropagationSeconds: false,
	holdTimeInSeconds: 0,
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
		if(! this.disablePropagationMinutes) { // Tells click on the editable shd stay thr itself
			$(".editable-popup").on("click", function(evt) {
				evt.stopPropagation();
			});
			this.disablePropagationMinutes = true;
		}
	},

	editSeconds: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		$(".editable-popup").find(".input-mini"). //Injecting attr s to number, editable doen't support number type
		attr("min", 0).
		attr("max", 59);
		if(! this.disablePropagationSeconds) { // Tells click on the editable shd stay thr itself
			$(".editable-popup").on("click", function(evt) {
				evt.stopPropagation();
			});
			this.disablePropagationSeconds = true;
		}
	},

	changeHoldTime: function() {

		console.log(this, this.minutes, this.seconds);
	},

	initialize: function() {
		this.holdTimeInSeconds = parseInt(this.model["hold_time"]);
		this.minutes = this.holdTimeInSeconds/60;
		this.seconds = this.holdTimeInSeconds%60;
	},

	render: function() {
		holdTimeObject = this;
		timeInSeconds = this.holdTimeInSeconds;
		minutes = (timeInSeconds >= 60) ? timeInSeconds / 60 : "0";
		seconds = timeInSeconds % 60;
		minutes = (minutes < 10) ? "0"+minutes.toString() : minutes;
		seconds = (seconds < 10) ? "0"+seconds.toString() : seconds;
		time = {
			minutes: minutes,
			seconds: seconds
		}
		$(this.el).html(this.template(time));
		$(this.el).find(".seconds").on("init", function(e, editable) {
			
		});
		//Two handlers can be combined below but it will take some 
		//complex code to figure out right function call. So this way, less complex
		$(this.el).find(".seconds ").editable({
           type:  'number',
           title: 'Seconds',
           name:  'seconds',
           success:   function(respo, newval) {
           		holdTimeObject.seconds = parseInt(newval);
           		holdTimeObject.changeHoldTime();
           }
	    });

	    $(this.el).find(".minutes").editable({
           type:  'number',
           title: 'Minutes',
           name:  'minutes',
           success:   function(respo, newval) {
           		console.log(newval);
           		holdTimeObject.minutes = parseInt(newval);
           		holdTimeObject.changeHoldTime();
           }
	    });
		return this
	}

});