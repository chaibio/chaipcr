class ChaiBioTech.Routers.appRouter extends Backbone.Router

	loginScreen: {}

	homePage: {}

	iniitialize: () ->
		#console.log "wow";

	routes:
		"login": "logMeIn"
		"home": "loadHome"
		"edit-exp/:id": "editExp" # Remember this is the one for bringing up menu overlay
		"edit-stage-step/:id": "loadStepStage"

	logMeIn: () ->
		@loginScreen = new ChaiBioTech.app.Views.login
		$("#container").html(@loginScreen.render().el)

	loadHome: () ->
		if @loggedIn() is true
			data =
			"user": @loginScreen.user

			@homePage = new ChaiBioTech.app.Views.homePage data
			$("#container").html(@homePage.render().el)
		else
			location.href = "#/login"

	loggedIn: () ->
		if @loginScreen.loggedIn
			return yes
		return no

	editExp: (id) ->
		@menuOverLay = new ChaiBioTech.app.Views.menuOverLay
		$("#container").append(@menuOverLay.render().el)

	loadStepStage: (id) ->
		ExpModel = new ChaiBioTech.Models.Experiment({"id": id});
		@editStageStep = new ChaiBioTech.app.Views.editStageStep({
				model: ExpModel
			});
		$("#container").html(@editStageStep.render().el);
		this.canvas = new ChaiBioTech.app.Views.fabricCanvas();
