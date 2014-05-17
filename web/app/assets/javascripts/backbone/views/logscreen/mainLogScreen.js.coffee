ChaiBioTech.Views.temperatureLog = ChaiBioTech.Views.temperatureLog || {} ;

class ChaiBioTech.Views.temperatureLog.main extends Backbone.View
	
	template: JST["backbone/templates/logscreen/main"]

	initialize: () ->
		console.log "this is okay"
	
	render: () ->
		$(@el).html(@template())
		return this




