ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.tempControl = Backbone.View.extend({
	
	template: JST["backbone/templates/design/step"],
	className: 'tempBar',
	dragged: false,
	myTemperature: 0,
	events: {
		"click": "disablePropagation",
		"click .editTemp": "changeTempManually"
	},

	disablePropagation: function(evt) {
		evt.stopPropagation();
	},
	
	changeTempManually: function(evt) {
		//alert("hola");
		evt.preventDefault();
		evt.stopPropagation();
		if( !this.dragged ) {
			$(this.el).find(".editTemp").editable('show');
			$(".editable-popup").find(".input-mini"). 
			attr("min", 0).
			attr("max", 100).
			attr("step", .1);
			$(this.el).find(".editTemp").editable('option', 'value', this.myTemperature);
		} else {
			$(this.el).find(".editTemp").editable('hide');
		}
		this.dragged = false;
	},

	initialize: function() {
		this.myTemperature = this.model.temperature;
		if(! _.isNull(ChaiBioTech.Data.previousLine)) {

			this.line = new ChaiBioTech.Views.Design.line({
				model: this.model,
				previousLine: ChaiBioTech.Data.previousLine
			});
		} else {

			this.line = new ChaiBioTech.Views.Design.line({
				model: this.model
			});
		}

		ChaiBioTech.Data.previousLine = this.line; //Saves line object to make a linkedlist

		var originalObject;
		// Draggable event handler
		$(this.el).draggable({
				containment: "parent",
				axis: "y",

				start: function() {
					originalObject = $(this).data("data-thisObject");
					parentStep = originalObject.options.parentStep;
				},
				drag: function() {
					number = 100 - ((parseInt($(originalObject.el).css("top")) * 100 )/ ChaiBioTech.Constants.stepHeight);
					number = number.toFixed(1);
					$(this).find(".editTemp").html(number);
					//$(this).data("data-temperature", number);
					originalObject.line.trigger("moveThisLine", {"toThisTemp": number});
				},

				stop: function() {
					number = 100 - ((parseInt($(originalObject.el).css("top")) * 100 )/ ChaiBioTech.Constants.stepHeight);
					number = number.toFixed(1);
					$(this).find(".editTemp").html(number);
					$(this).data("data-temperature", number);
					originalObject.dragged = true;
					originalObject.myTemperature = number;
					parentStep.trigger("changeTemperature", number);
					parentStep.holdTime.trigger("tempChanged", number);
					originalObject.line.trigger("moveThisLine", {"toThisTemp": number});
					console.log(this);
				}
		});

	},
	
	render:function() {
		temperature = this.model.temperature;
		$(this.el).html(this.template(this.model));
		//This line saves this object within the element so that the wrong reference due to draggable can be tackled
		$(this.el).data("data-thisObject", this); 
		$(this.el).append(this.line.render().el);
		// Editable event handler
		$(this.el).find(".editTemp").editable({
			type:  'number',
	       	title: 'Temperature',
	       	name:  'Temp',
           	success:   function(respo, newval) {
           		
           	}
		});

		$(this.el).find(".editTemp").on('init', function(e, editable) {
		    alert("bingo");
		});
		return this;
	}
});