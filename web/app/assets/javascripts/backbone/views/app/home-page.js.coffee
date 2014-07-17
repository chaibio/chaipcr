ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePage extends Backbone.View

	template: JST["backbone/templates/app/home-page"]
	
	initialize: () ->
		@loadMenu()
		@loadExperimentInProgress()

	loadMenu: () ->
		data = 
			user: @options.user

		@menuBLOCK = new ChaiBioTech.app.Views.homePageMenu data

	loadExperimentInProgress: () ->
		@experimentInProgress = new ChaiBioTech.app.Views.experimentInProgress


	render: () ->
		$(@el).html @template()
		# Placing Menu
		$(@el).find(".home-page-menu").html(@menuBLOCK.render().el)
		# Plecing Experiment in progress
		$(@el).find(".experiment-in-progress-container").html(@experimentInProgress.render().el)
		return this




