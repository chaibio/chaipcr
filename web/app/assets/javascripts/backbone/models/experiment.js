ChaiBioTech.Models.Experiment = ChaiBioTech.Models.Experiment || {};

ChaiBioTech.Models.Experiment = Backbone.Model.extend({
	
	url: "/experiments",

	defaults: {

		experiment: {
			name: "",
			qpcr: true,
			protocol: {

			}
		}
	},

	initialize: function(){
		_.bindAll(this ,"afterSave");
	},
	saveData: function() {
		//var data = this.toJSON();
		/*$.post("/experiments", data)
			.done(function(dataReturned){
				console.log(dataReturned);
				return "Saved";
			})
			.fail(function() {
				console.log("failed");
			}); */
		this.save(null, { success: this.afterSave });
	},

	afterSave: function(response) {
		this.trigger("Saved");
	}
});

ChaiBioTech.Collections.Experiment = ChaiBioTech.Collections.Experiment || {};

ChaiBioTech.Collections.Experiment = Backbone.Collection.extend({

	model: ChaiBioTech.Models.Experiment,
	
	url: "/experiments"	
})