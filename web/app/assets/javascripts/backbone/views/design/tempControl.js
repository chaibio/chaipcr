ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.tempControl = Backbone.View.extend({
	
	template: JST["backbone/templates/design/step"],
	className: 'tempBar',
	dragAdded: false,
	
	initialize: function() {
		
		//bring line component in here, so that as we move this object it moves along;
		//a line object should reference to the next line object;
		//when one is dragged along two lines has to update..!
		//One fixed in the drag object and the one very next to it.. !
		// all the math is in steps js , move it may be move into line itself, but that might be a problem because we need to place it first 
		// or may be a seperate function so that i is called after render..!!

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
				},

				stop: function() {
					originalObject = $(this).data("data-thisObject");
					temp = parseFloat($(this).data("data-temperature"));
					parentStep = originalObject.options.parentStep;
					parentStep.trigger("changeTemperature", temp);
				}
		});
	},
	
	render:function() {
		temperature = this.options["stepData"]["step"]["temperature"];
		console.log(temperature * 1.57)
		$(this.el).html(this.template(this.options["stepData"]["step"]));
		//This line saves this object within the element so that the wrong reference due to draggable can be tackled
		$(this.el).data("data-thisObject", this); 
		return this;
	}
});