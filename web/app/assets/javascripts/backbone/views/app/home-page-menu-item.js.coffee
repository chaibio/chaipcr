ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.homePageMenuItem extends Backbone.View

	template: JST["backbone/templates/app/home-page-menu-item"]

	className: "menu-item"

	bounced: false

	originalHeight: 50

	events :
		"mouseenter .first-row": "bounce" # When mouse enter
		"mouseleave .first-row": "bounceBack" # When mouse leaves
	
	initialize: () ->
		#Menu Item comes alive here
		console.log "Menu Item", @

	render: () -> 
		data = 
			"menuValue": @options.menuValue

		$(@el).html(@template(data))
		return this;

	bounceWithValue: (value) ->
		$(@el).css("height", "#{@originalHeight + value}px");
		@goNext(this, value / 2)
		@goPrevious(this, value / 2)

	goNext: (tempThis, value) ->
		if tempThis.next
			tempVal = tempThis.next
			$(tempVal.el).css("height", "#{@originalHeight + value}px")
			tempVal.goNext(tempVal, value / 2)

	goPrevious: (tempThis, value) ->
		if tempThis.previous
			tempVal = tempThis.previous
			$(tempVal.el).css("height", "#{@originalHeight + value}px")
			tempVal.goPrevious(tempVal, value / 2)

	bounceBackWithValue: (@value) ->
		height = $(@el).height()
		$(@el).css("height", "#{@originalHeight - value}px")
		if @.previous
			@.previous.bounceWithValue(value / 2)
	
	bounce: () ->
		@bounceWithValue(50)
			

	bounceBack: () ->
		#@bounceBackWithValue(50)

		
		



