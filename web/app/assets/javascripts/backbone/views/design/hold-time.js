ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.holdTime = Backbone.View.extend({

	template: JST["backbone/templates/design/hold-time"],
	holdTimeInSeconds: 0,
	className: "hold-time",
	events: {
		"click .minutes": "editMinute",
		"click .seconds": "editSeconds"
	},

	editMinute: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		//Injecting attr s to number, editable doen't support number type
		$(".editable-popup").find(".input-mini").
		attr("min", 0).
		attr("max", 59);
		$(".editable-popup").on("click", function(evt) {
			evt.stopPropagation();
		});
	},

	editSeconds: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		//Injecting attrs to number, editable doen't support input typt=number
		$(".editable-popup").find(".input-mini").
		attr("min", 0).
		attr("max", 59);
		$(".editable-popup").on("click", function(evt) {
			evt.stopPropagation();
		});
	},

	changeHoldTime: function() {
		this.holdTimeInSeconds = (this.minutes * 60) + this.seconds;
		this.options.grandParent.chngeHoldTime(this.holdTimeInSeconds, this.model)
		$(this.el).html("");
		this.render();
	},

	initialize: function() {
		this.holdTimeInSeconds = parseInt(this.model["hold_time"]);
		this.minutes = Math.floor(this.holdTimeInSeconds/60);
		this.seconds = this.holdTimeInSeconds%60;
		this.on("tempChanged", function(change) {
			$(this.el).animate({
				"top": ((100 - change) * ChaiBioTech.Constants.stepHeight)/100
			}, "fast");
		});
	},

	render: function() {
		holdTimeObject = this;
		timeInSeconds = this.holdTimeInSeconds;
		minutes = (timeInSeconds >= 60) ? Math.floor(timeInSeconds / 60) : "0";
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
           		thisPointer = $(this).data("data-thisSeconds");//Correcting the reference
           		thisPointer.seconds = parseInt(newval);
           		thisPointer.changeHoldTime();
           }
	    });

	    $(this.el).find(".minutes").editable({
           type:  'number',
           title: 'Minutes',
           name:  'minutes',
           success:   function(respo, newval) {
           		thisPointer = $(this).data("data-thisMinutes");//Correcting the reference
           		thisPointer.minutes = parseInt(newval);
           		thisPointer.changeHoldTime();
           }
	    });
	    $(this.el).find(".minutes").data("data-thisMinutes", this);
	    $(this.el).find(".seconds").data("data-thisSeconds", this);
		return this
	}

});
