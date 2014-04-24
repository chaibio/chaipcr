ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.tempControl = Backbone.View.extend({
	
	template: JST["backbone/templates/design/step"],
	className: 'tempBar',
	dragAdded: false,
	
	initialize: function() {

		if(! _.isUndefined(ChaiBioTech.Data.previousLine)) {

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

		$(this.el).draggable({
				containment: "parent",
				axis: "y",

				start: function() {
					
				},
				drag: function() {
					currentPosition = parseInt($(this).css("top").replace("px", ""), 10);
					//1.57 could be changed as we change interface , whatever the number is (tempControl container width)/100;
					number = (157 - currentPosition) / 1.57; 
					$(this).find(".label").html(number.toFixed(2));
					$(this).data("data-temperature", number.toFixed(2));
					originalObject = $(this).data("data-thisObject");
					originalObject.line.trigger("moveThisLine", {"toThisTemp": number.toFixed(2)});
				},

				stop: function() {
					// There is an issue when this is dragged really fast .. ! solve it.
					//may be we need to trigger here too, or may b we shdnt be triggering and call directly. 
					originalObject = $(this).data("data-thisObject");
					temp = parseFloat($(this).data("data-temperature"));
					parentStep = originalObject.options.parentStep;
					parentStep.trigger("changeTemperature", temp);
					//$(originalObject).css("top", 157 - (temp * 1.57) +"px");
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