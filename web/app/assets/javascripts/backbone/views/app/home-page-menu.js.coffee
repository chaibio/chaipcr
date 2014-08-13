ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenu extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu"]

	className: "menu-content"
		
	menuItems: ["NEW EXPERIMENT", "RUN A KIT", "SETTINGS"]

	events :
		"mouseleave": "render"

	initialize: () ->
		#Initialize

	render: () ->
		data = 
			"user": @options.user.toUpperCase()

		$(@el).html(@template(data))
		menuItems = null
		previousMenuItem = null
		for textToBePrinted in @menuItems
			data = 
				"menuValue": textToBePrinted
				"previousItem": menuItem

			menuItem = new ChaiBioTech.app.Views.homePageMenuItem(data)
			if previousMenuItem
				previousMenuItem.next = menuItem
				menuItem.previous = previousMenuItem
			
			previousMenuItem = menuItem
			$(@el).find(".menu-items").append(menuItem.render().el)

		# Hide the last hand :) I mean the last item in the menu and the black Line is the hand
		$(menuItem.el).find(".hand").hide()
		return this

