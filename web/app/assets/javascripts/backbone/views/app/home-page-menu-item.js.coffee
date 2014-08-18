ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenuItem extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu-item"]

	className: "menu-item"

	bounced: false

	originalHeight: 58

	events :
		"mouseenter .first-row": "bounce" # When mouse enter
		"mouseleave .first-row": "bounceBack" # When mouse leaves
	
	initialize: () ->
		#Menu Item comes alive here
		#console.log "Menu Item", @

	render: () -> 
		data = 
			"menuValue": @options.menuValue

		$(@el).html(@template(data))
		return this;
	
	bounce: (e) ->
		$(@el).find(".menu-item-text").css("font-weight", "bold")

	bounceBack: () ->
		$(@el).find(".menu-item-text").css("font-weight", "normal")

		
		



