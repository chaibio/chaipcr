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
		if(action == "update") {
			var data = this.get("experiment");
			dataToBeSend = {"experiment":{"name": data["name"]}}
			$.ajax({
				url: "/experiments/"+data["id"],
				contentType: 'application/json',
				type: 'PUT',
				data: JSON.stringify(dataToBeSend)
			})
			.done(function(data) {
				console.log(data);
			})
			.fail(function() {
				console.log("Failed to update");
			})
		}else {
			this.save(null, { success: this.afterSave });
		}
	},

	afterSave: function(response) {
		this.trigger("Saved");
	},

	createStep: function(step, targetStage) {
		//console.log(step);
		stage = step.options.parentStage.model;
		console.log("step",step);
		dataToBeSend = {"step":{},
			"prev_id": step.model.id
		};
		console.log("Data To Server", dataToBeSend);
		$.ajax({
			url: "/stages/"+stage.id+"/steps",
			contentType: 'application/json',
			type: 'POST',
			data: JSON.stringify(dataToBeSend)
		})
		.done(function(data) {
			console.log(data);
			targetStage.addStep(data);
		})
		.fail(function() {
			console.log("Failed to update");
		}); 
	}
});

ChaiBioTech.Collections.Experiment = ChaiBioTech.Collections.Experiment || {};

ChaiBioTech.Collections.Experiment = Backbone.Collection.extend({

	model: ChaiBioTech.Models.Experiment,
	
	url: "/experiments"	
})