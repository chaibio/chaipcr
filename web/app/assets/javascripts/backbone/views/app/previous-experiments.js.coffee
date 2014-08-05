ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.previousExperiments extends Backbone.View

	template: JST["backbone/templates/app/previous-experiments"]

	dots: ""

	allExpDiv: ""

	deleteSwitch: false

	deleteSwitchOn:
		color: "#00aeef"

	deleteSwitchOff:
		color: "orange"

	events: 
		"click .dots": "enableDelete"

	initialize: () ->
		# Initialize
		# We bind it so that we dont lose the reference as collection
		# fetch data
		_.bindAll(this, "getPreviousExperiment") # Correcting the refrence
		@experimentCollection = new ChaiBioTech.Collections.Experiment

	enableDelete: () ->
		# Invoked when we click on the dots at the top-right
		# Triggeres event for previous-experiment object
		# Changes color on click
		@deleteSwitch = ! @deleteSwitch
		if @deleteSwitch is true
			@dots.css(@deleteSwitchOn)
		else
			@dots.css(@deleteSwitchOff)

		@trigger("readyToDelete")

	getPreviousExperiment: (coll, respo) ->
		# Invoked when we successfully fetch all the experiment data
		# Creates single experiments and added to the Dom
		for exp in coll.models
			data = 
				parent: this
				model: exp

			experiment = new ChaiBioTech.app.Views.experiment(data)
			@allExpDiv.prepend(experiment.render().el)

	loadPreviousExperiments: () ->
		# Bring All the experiments from database
		@experimentCollection.fetch({success: @getPreviousExperiment})

	render: () ->
		$(@el).html(@template())
		@dots = $(@el).find(".dots")
		@allExpDiv = $(@el).find(".all-experiments").html("")
		return this


