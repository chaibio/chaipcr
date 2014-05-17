class ChaiBioTech.Routers.temperatureLog extends Backbone.Router

	initialize: () ->
		console.log "this is initiated"

	routes:
		"temperatureLog": "initiateLogScreen"

	initiateLogScreen: () ->
		mainView = new ChaiBioTech.Views.temperatureLog.main
		$("#container").append mainView.render().el


		

	
