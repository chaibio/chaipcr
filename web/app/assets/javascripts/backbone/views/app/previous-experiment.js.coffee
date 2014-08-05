ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.experiment extends Backbone.View

	template: JST["backbone/templates/app/previous-experiment"]

	className: "individual-experiment"

	image: ""

	hand: ""

	readyToDeleteTrueImage:
		backgroundImage: "url('assets/smallredO.png')"

	readyToDeleteFalseImage: 
		backgroundImage: "url('assets/smallblackO.png')"

	readyToDeleteTrueHand:
		backgroundColor: "#a61300"

	readyToDeleteFalseHand:
		backgroundColor: "#00aeef"

	readyToDelete: false

	initialize: () ->
		@experimentClass = @options.parent
		@listenTo(@experimentClass ,"readyToDelete", @enableDelete)

	enableDelete: () ->
		@readyToDelete = ! @readyToDelete
		
		if @readyToDelete is true
			@image.css(@readyToDeleteTrueImage)
			@hand.css("background-color", "#a61300")
		else
			@image.css(@readyToDeleteFalseImage)
			@hand.css("background-color", "#00aeef")

	render: () ->
		data =
			"name": @model.get("experiment").name

		$(@el).html(@template(data))
		@image = $(@el).find(".image")
		@hand = $(@el).find(".hand")
		return this



