class ChaiBioTech.Routers.appRouter extends Backbone.Router

	loginScreen: {}
	
	homePage: {}

	iniitialize: () ->
		#console.log "wow";

	routes:
		"login": "logMeIn"
		"home": "loadHome"
		"edit-exp/:id": "editExp"

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












