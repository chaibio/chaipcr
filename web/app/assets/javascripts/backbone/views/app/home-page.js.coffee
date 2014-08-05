ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePage extends Backbone.View

	template: JST["backbone/templates/app/home-page"]
	
	initialize: () ->
		@loadMenu()
		@loadExperimentInProgress()
		@loadPreviousExperiments()

	loadMenu: () ->
		data = 
			user: @options.user

		@menuBLOCK = new ChaiBioTech.app.Views.homePageMenu data

	loadExperimentInProgress: () ->
		@experimentInProgress = new ChaiBioTech.app.Views.experimentInProgress

	loadPreviousExperiments: () ->
		@previousExperiments = new ChaiBioTech.app.Views.previousExperiments

	render: () ->
		$(@el).html @template()
		# Placing Menu
		$(@el).find(".home-page-menu").html(@menuBLOCK.render().el)
		# Placing Experiment in progress
		$(@el).find(".experiment-in-progress-container").html(@experimentInProgress.render().el)
		# Placing previous experiments template
		$(@el).find(".home-page-right-wing").html(@previousExperiments.render().el)
		# Now we load all the previous experiments
		@previousExperiments.loadPreviousExperiments()
		return this




