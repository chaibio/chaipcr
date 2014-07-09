ChaiBioTech.Views.app = ChaiBioTech.Views.app || {}

class ChaiBioTech.Views.app.login extends Backbone.View

	template: JST["backbone/templates/app/login-page"]

	initialize: () ->
		console.log @template

	render: () ->
		$(@el).html(@template())
		return @

