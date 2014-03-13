ChaiBioTech.Models.Experiment = ChaiBioTech.Models.Experiment || {};

ChaiBioTech.Models.Experiment = Backbone.Model.extend({
	
	defaults: {

		name: "",
		qpcr: true

	},

	initialize: function(){

	},
	saveData: function() {
		alert("all the way up here");
		console.log(this.collection);
	}
});

ChaiBioTech.Collections.Experiment = ChaiBioTech.Collections.Experiment || {};

ChaiBioTech.Collections.Experiment = Backbone.Collection.extend({

	model: ChaiBioTech.Models.Experiment,
	
	url: "/experiments"	
})