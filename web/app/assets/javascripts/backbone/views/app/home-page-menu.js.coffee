ChaiBioTech.Views.app = ChaiBioTech.Views.app || {}

class ChaiBioTech.Views.app.homePageMenu extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu"]
	className: "menu-content"

	initialize: () ->
		console.log("u r awesome .. !", @options)

	render: () ->
		data = 
			"user": @options.user.toUpperCase()

		$(@el).html(@template(data))
		return this

