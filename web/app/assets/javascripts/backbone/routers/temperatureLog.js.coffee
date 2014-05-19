class ChaiBioTech.Routers.temperatureLog extends Backbone.Router

	initialize: () ->
		console.log "this is initiated"

	routes:
		"temperatureLog": "initiateLogScreen"

	initiateLogScreen: () ->
		mainView = new ChaiBioTech.Views.temperatureLog.main
		$("#container").append mainView.render().el
		r = new Raphael("graph")
		console.log r.linechart
		r.linechart(0, 0, 99, 99, [1,2,3,4,5], [[1,2,3,4,5], [1,3,9,16,25], [100,50,25,12,6]], {smooth: true, colors: ['#F00', '#0F0', '#FF0'], symbol: 'circle'});



		

	
