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

	bounceWithValue: (value, valueOfHand) ->
		$(@el).css("height", "#{@originalHeight + value}px")
		$(@el).find(".hand").css("height", "#{22 + valueOfHand}px")
		console.log $(@el).find(".hand").css("height")
		@goNext(this, value / 2, valueOfHand / 2)
		@goPrevious(this, value / 2, valueOfHand / 2)

	goNext: (tempThis, value, valueOfHand) ->
		if tempThis.next
			tempVal = tempThis.next
			$(tempVal.el).css("height", "#{@originalHeight + value}px")
			$(tempVal.el).find(".hand").css("height", "#{22 + valueOfHand}px")
			tempVal.goNext(tempVal, value / 2, valueOfHand / 2)

	goPrevious: (tempThis, value, valueOfHand) ->
		if tempThis.previous
			tempVal = tempThis.previous
			$(tempVal.el).css("height", "#{@originalHeight + value}px")
			$(tempVal.el).find(".hand").css("height", "#{22 + valueOfHand}px")
			tempVal.goPrevious(tempVal, value / 2, valueOfHand / 2)

	bounceBackWithValue: (@value) ->
		height = $(@el).height()
		$(@el).css("height", "#{@originalHeight - value}px")
		if @.previous
			@.previous.bounceWithValue(value / 2)
	
	bounce: (e) ->
		$(@el).find(".menu-item-text").css("font-weight", "bold")

	bounceBack: () ->
		$(@el).find(".menu-item-text").css("font-weight", "normal")

		
		



