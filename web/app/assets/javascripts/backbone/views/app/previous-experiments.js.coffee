ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.previousExperiments extends Backbone.View

	template: JST["backbone/templates/app/previous-experiments"]

	initialize: () ->
		# Initialize
		# We bind it so that we dont lose the reference as collection
		# fetch data
		_.bindAll(this, "getPreviousExperiment") # Correcting the refrence
		@experimentCollection = new ChaiBioTech.Collections.Experiment

	getPreviousExperiment: (coll, respo) ->
		allExpDiv = $(@el).find(".all-experiments").html("")
		for exp in coll.models
			data = 
				parent: this
				model: exp

			experiment = new ChaiBioTech.app.Views.experiment(data)
			allExpDiv.prepend(experiment.render().el)

	loadPreviousExperiments: () ->
		@experimentCollection.fetch({success: @getPreviousExperiment})

	render: () ->
		$(@el).html(@template())
		return this


