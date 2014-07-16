ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenuItem extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu-item"]
	className: "menu-item"
	events :
		"mouseenter .menu-item": "bounce"
		"mouseleave .menu-item": "bounceBack"
	initialize: () ->
		#Menu Item comes alive here

	render: () -> 
		data = 
			"menuValue": @options.menuValue

		$(@el).html(@template(data))
		return this;

	bounce: () ->
		$(@el).attr("class", "menu-item-bounce")

	bounceBack: () ->
		$(@el).attr("class", "menu-item")



