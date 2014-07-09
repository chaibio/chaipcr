class ChaiBioTech.Routers.appRouter extends Backbone.Router

	iniitialize: () ->
		console.log "wow";

	routes:
		"login": "logMeIn"

	logMeIn: () ->
		@loginScreen = new ChaiBioTech.Views.app.login
		$("#container").html(@loginScreen.render().el)








