ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.holdTime = Backbone.View.extend({
	
	template: JST["backbone/templates/design/hold-time"],
	events: {
		"click .minutes": "editMinute",
		"click .seconds": "editSeconds"
	},

	editMinute: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
		$(".editable-popup").find(".input-mini").
		attr("min", 0).
		attr("max", 59);
		console.log($(".editable-popup").find(".input-mini"));
	},

	editSeconds: function(evt) {
		evt.preventDefault();
		evt.stopPropagation();
	},

	initialize: function() {
		console.log(this.model["hold_time"]);
	},

	render: function() {
		timeInSeconds = parseInt(this.model["hold_time"]);
		minutes = (timeInSeconds >= 60) ? timeInSeconds / 60 : "0";
		seconds = timeInSeconds % 60;
		minutes = (minutes < 10) ? "0"+minutes.toString() : minutes;
		seconds = (seconds < 10) ? "0"+seconds.toString() : seconds;
		console.log(minutes, seconds);
		time = {
			minutes: minutes,
			seconds: seconds
		}
		$(this.el).html(this.template(time));
		$(this.el).find(".seconds").on("init", function(e, editable) {
			
		});
		$(this.el).find(".seconds").editable({
           type:  'number',
           title: 'Seconds',
           name:  'seconds',
           success:   function(respo, newval) {
           		//thisPointer.editStageName(newval);
           		alert("okay");
           }
	    });

	    $(this.el).find(".minutes").editable({
           type:  'number',
           title: 'Minutes',
           name:  'minutes',
           success:   function(respo, newval) {
           		//thisPointer.editStageName(newval);
           		alert("okay");
           }
	    });
		return this
	}

});