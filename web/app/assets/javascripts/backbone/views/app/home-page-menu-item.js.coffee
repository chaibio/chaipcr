ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenuItem extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu-item"]
	className: "menu-item"
	events :
		"mouseenter .menu-item": "bounce" # When mouse enter
		"mouseleave .menu-item": "bounceBack" # When mouse leaves
	initialize: () ->
		#Menu Item comes alive here

	render: () -> 
		data = 
			"menuValue": @options.menuValue

		$(@el).html(@template(data))
		return this;

	bounce: () ->
		$(@el).switchClass("menu-item", "menu-item-bounce", 5)
		# We change classes so that all within changes
		# If not the first entry in the menu list we have to adjust for the entry above too
		if @options.previousItem?
			previousMenuItem = @options.previousItem
			$(previousMenuItem.el).switchClass("menu-item", "menu-item-previous-bounce", 5)
			

	bounceBack: () ->
		$(@el).switchClass("menu-item-bounce", "menu-item", 5)
		# Revert the class to original
		# If not the first entry in the menu list we have to adjust for the entry above too
		if @options.previousItem?
			previousMenuItem = @options.previousItem
			$(previousMenuItem.el).switchClass("menu-item-previous-bounce", "menu-item", 5)



