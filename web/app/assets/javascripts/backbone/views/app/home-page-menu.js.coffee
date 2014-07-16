ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenu extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu"]
	className: "menu-content"
	menuItems: ["NEW EXPERIMENT", "RUN A KIT", "SETTINGS"]

	initialize: () ->
		#console.log("u r awesome .. !", @options)

	render: () ->
		data = 
			"user": @options.user.toUpperCase()

		$(@el).html(@template(data))
		menuItems = ""

		for textToBePrinted in @menuItems
			data = 
				"menuValue":textToBePrinted

			menuItem = new ChaiBioTech.app.Views.homePageMenuItem(data)
			$(@el).find(".menu-items").append(menuItem.render().el)

		# Hide the last hand
		$(menuItem.el).find(".hand").hide()
		return this

