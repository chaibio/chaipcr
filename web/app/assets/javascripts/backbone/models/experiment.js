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
		that = this;
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
					console.log("Boom", data, that);
			})
			.fail(function() {
				console.log("Failed to update");
			})
		}else {
			this.save(null, { success: this.afterSave });
		}
	},

	afterSave: function(response) {
		console.log(response);
		this.trigger("Saved");
	},

	createStep: function(step, place) {
		that = this;
		stage = step.options.parentStage.model;
		dataToBeSend = {};
		if(place == "before" && step.options.prev_id != null) {
			dataToBeSend = {"prev_id": step.options.prev_id};
		} else {
			dataToBeSend = {"prev_id": step.model.id}
		}

		console.log("Data To Server", dataToBeSend);
		$.ajax({
			url: "/stages/"+stage.id+"/steps",
			contentType: 'application/json',
			type: 'POST',
			data: JSON.stringify(dataToBeSend)
		})
		.done(function(data) {
			that.getLatestModel();
		})
		.fail(function() {
			alert("Failed to update");
			console.log("Failed to update");
		}); 
	},

	createStage: function(type, stageData) {
		that = this;
		var data = this.get("experiment");
		dataToBeSend = {
			"stage": {
				'stage_type': type
			}
		};
		if(!_.isNull(stageData.options.prev_stage_id)) {
			dataToBeSend["stage"]["prev_id"] = stageData.model.id
		}
		console.log("Data To Server", dataToBeSend);
		$.ajax({
			url: "/protocols/"+data.id+"/stages",
			contentType: 'application/json',
			type: 'POST',
			data: JSON.stringify(dataToBeSend)
		})
		.done(function(data) {
			that.getLatestModel();
		})
		.fail(function() {
			alert("Failed to update");
			console.log("Failed to update");
		}); 
	},

	getLatestModel: function(callback) {
		that = this;
		var data = this.get("experiment");
		$.ajax({
			url: "/experiments/"+data["id"],
			contentType: 'application/json',
			type: 'GET'
		})
		.done(function(data) {
				console.log("Big bang", that);
				that.set('experiment', data["experiment"]);
				that.trigger("modelUpdated");	
		})
		.fail(function() {
			console.log("Failed to update");
		})
	},

	deleteStep: function(step) {
		that = this;
		$.ajax({
			url: "/steps/"+step.model.id,
			contentType: 'application/json',
			type: 'DELETE'
		})
		.done(function(data) {
			console.log(data);
			that.getLatestModel(function() {
				step.deleteView();
			});
		})
		.fail(function() {
			alert("Failed to update");
			console.log("Failed to update");
		}); 
	}
});

ChaiBioTech.Collections.Experiment = ChaiBioTech.Collections.Experiment || {};

ChaiBioTech.Collections.Experiment = Backbone.Collection.extend({

	model: ChaiBioTech.Models.Experiment,
	
	url: "/experiments"	
})