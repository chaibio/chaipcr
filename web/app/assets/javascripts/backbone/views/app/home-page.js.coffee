ChaiBioTech.Views.app = ChaiBioTech.Views.app || {}

class ChaiBioTech.Views.app.homePage extends Backbone.View

	template: JST["backbone/templates/app/home-page"]
	
	initialize: () ->
		@loadMenu()

	loadMenu: () ->
		data = 
			user: @options.user

		@menuBLOCK = new ChaiBioTech.Views.app.homePageMenu data

	render: () ->
		$(@el).html @template()
		$(@el)
		.find(".home-page-menu")
		.html(@menuBLOCK.render().el)
		return this




