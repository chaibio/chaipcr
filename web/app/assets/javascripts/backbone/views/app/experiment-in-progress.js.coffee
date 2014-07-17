ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.experimentInProgress extends Backbone.View

	template: JST["backbone/templates/app/experiment-in-progress"]
	className: "experiment-in-progress"

	initialize: () ->
		@getExperimentInProgress()

	render: () ->
		$(@el).html(@template(@experimentData))
		wholeWidth = 442 #its set in the css we may move it to constants
		propgressWidth = wholeWidth * (@experimentData.experiment_percentage / 100)
		$(@el).find(".progress-bar").css("width", "#{propgressWidth}px")
		return this

	getExperimentInProgress: ()->
		# Here we will implement some AJAX call
		# that would return some data, Now we use
		# a dummy object
		@experimentData =
			"experiment_name": "MALARIA TEST ALPHA"
			"experiment_stage": "STAGE 3, STEP 2"
			"experiment_time_remaining": "01:13:03"
			"experiment_percentage": "60"




