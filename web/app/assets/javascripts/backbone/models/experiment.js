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
	saveData: function( action ) {
		var that = this;
		if(action == "update") {
			var data = this.get("experiment");
			console.log("Boom", {"experiment":{"id":73,"name":"Bingo jossie","qpcr":true,"run_at":null}});
			$.ajax({
				url: "experiment/"+data["id"],
				contentType: 'application/json',
				method: 'PUT',
				data: JSON.stringify({"experiment":{"id":73,"name":"Bingo jossie","qpcr":true,"run_at":null}}),
			})
			.done(function(data) {
				alert("Okay")
			})
			.fail(function() {
				alert("failed");
			})
		}else {
			alert("save");
			this.save(null, { success: this.afterSave });
		}
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