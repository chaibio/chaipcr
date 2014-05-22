ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.tempControl = Backbone.View.extend({
	
	template: JST["backbone/templates/design/step"],
	className: 'tempBar',
	dragAdded: false,

	events: {
		"click": "disablePropagation"
	},

	disablePropagation: function(evt) {
		evt.stopPropagation();
	},
	
	initialize: function() {

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
					$(this).find(".label").html(number);
					$(this).data("data-temperature", number);
					originalObject.line.trigger("moveThisLine", {"toThisTemp": number});
				},

				stop: function() {
					number = 100 - ((parseInt($(originalObject.el).css("top")) * 100 )/ ChaiBioTech.Constants.stepHeight);
					number = number.toFixed(1);
					$(this).find(".label").html(number);
					parentStep.trigger("changeTemperature", number);
					parentStep.holdTime.trigger("tempChanged", number);
					originalObject.line.trigger("moveThisLine", {"toThisTemp": number});
				}
		});
	},
	
	render:function() {
		temperature = this.model.temperature;
		$(this.el).html(this.template(this.model));
		//This line saves this object within the element so that the wrong reference due to draggable can be tackled
		$(this.el).data("data-thisObject", this); 
		$(this.el).append(this.line.render().el);
		
		return this;
	}
});