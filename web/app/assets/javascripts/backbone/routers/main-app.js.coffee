class ChaiBioTech.Routers.appRouter extends Backbone.Router

	loginScreen: {}
	homePage: {}

	iniitialize: () ->
		console.log "wow";

	routes:
		"login": "logMeIn"
		"home": "loadHome"

	logMeIn: () ->
		@loginScreen = new ChaiBioTech.Views.app.login
		$("#container").html(@loginScreen.render().el)

	loadHome: () ->
		if @loggedIn()
			data = 
			"user": @loginScreen.user

			@homePage = new ChaiBioTech.Views.app.homePage data
			$("#container").html(@homePage.render().el)
		else
			location.href = "#/login"

	loggedIn: () ->
		if @loginScreen.loggedIn
			return true

		return false











