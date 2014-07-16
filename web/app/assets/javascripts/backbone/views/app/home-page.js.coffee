ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePage extends Backbone.View

	template: JST["backbone/templates/app/home-page"]
	
	initialize: () ->
		@loadMenu()

	loadMenu: () ->
		data = 
			user: @options.user

		@menuBLOCK = new ChaiBioTech.app.Views.homePageMenu data

	render: () ->
		$(@el).html @template()
		$(@el)
		.find(".home-page-menu")
		.html(@menuBLOCK.render().el)
		return this




