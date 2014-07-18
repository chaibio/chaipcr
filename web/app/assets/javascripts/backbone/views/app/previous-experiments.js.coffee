ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.previousExperiments extends Backbone.View

	template: JST["backbone/templates/app/previous-experiments"]

	initialize: () ->
		# Initialize

	render: () ->
		$(@el).html(@template())
		return this


