ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.experiment extends Backbone.View

	template: JST["backbone/templates/app/previous-experiment"]

	className: "individual-experiment"

	image: ""

	hand: ""

	readyToDeleteTrueImage:
		backgroundImage: "url('assets/smallredO.png')"
		cursor: "pointer"

	readyToDeleteFalseImage: 
		backgroundImage: "url('assets/smallblackO.png')"

	readyToDeleteTrueHand:
		backgroundColor: "#a61300"

	readyToDeleteFalseHand:
		backgroundColor: "#00aeef"

	readyToDelete: false

	events: 
		"click .image": "deleteExperimentConfirm"
		"click .no-delete": "dontDelete"
		"click .yes-delete": "yesDelete"

	initialize: () ->
		@experimentClass = @options.parent
		@listenTo(@experimentClass ,"readyToDelete", @enableDelete)

	enableDelete: () ->
		@readyToDelete = ! @readyToDelete
		
		if @readyToDelete is true
			@image.css(@readyToDeleteTrueImage)
			@hand.css(@readyToDeleteTrueHand)
		else
			@image.css(@readyToDeleteFalseImage)
			@hand.css(@readyToDeleteFalseHand)
			$(@el).find(".confirm-box").hide("slow");

	render: () ->
		data =
			"name": @model.get("experiment").name

		$(@el).html(@template(data))
		@image = $(@el).find(".image")
		@hand = $(@el).find(".hand")
		return this

	deleteExperimentConfirm: () ->
		# Shows a confirm box to delete
		if @readyToDelete is true
			$(@el).find(".confirm-box").show("fast")

	dontDelete: () ->
		$(@el).find(".confirm-box").hide("slow")

	yesDelete: () ->
		#@console.log @
		@model.destroy()
		callBack = () -> # Defining a local call back to pass to animate
			@.remove()

		action = 
			height: "0px"

		$(@.el).animate(action, 500, callBack)
		





