ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenu extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu"]

	className: "menu-content"
		
	menuItems: ["NEW EXPERIMENT", "RUN A KIT", "SETTINGS"]

	initialize: () ->
		#Initialize

	render: () ->
		data = 
			"user": @options.user.toUpperCase()

		$(@el).html(@template(data))
		for textToBePrinted in @menuItems
			data = 
				"menuValue": textToBePrinted

			menuItem = new ChaiBioTech.app.Views.homePageMenuItem(data)
			$(@el).find(".menu-items").append(menuItem.render().el)

		# Hide the last hand :) I mean the last item in the menu and the black Line is the hand
		$(menuItem.el).find(".hand").hide()
		firstMenuItem = $(@el).find(".menu-item")[0]
		# So the first item in the menu is gone bigger
		$(firstMenuItem).switchClass("menu-item", "menu-item-bounce")
		return this

