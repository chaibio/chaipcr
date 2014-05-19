ChaiBioTech.Views.temperatureLog = ChaiBioTech.Views.temperatureLog || {} ;

class ChaiBioTech.Views.temperatureLog.main extends Backbone.View
	
	template: JST["backbone/templates/logscreen/main"]

	initialize: () ->
		console.log "this is okay"
	
	render: () ->
		#r = Raphael(10, 50, 640, 480)
		#r.piechart(320, 240, 100, [55, 20, 13, 32, 5, 1, 2])
		#console.log r.linechart
		$(@el).html(@template())
		return this




