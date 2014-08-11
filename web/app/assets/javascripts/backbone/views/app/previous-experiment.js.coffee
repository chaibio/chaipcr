ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.experiment extends Backbone.View

	template: JST["backbone/templates/app/previous-experiment"]

	today: new Date()
	
	Months: ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
	
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
		@todayTimeStamp = Date.parse("#{@today.getFullYear()}/#{@today.getMonth()}/#{@today.getDate()}")
		@experimentClass = @options.parent
		@listenTo(@experimentClass ,"readyToDelete", @enableDelete)
		#console.log "Today ", @todayTimeStamp, @today.getFullYear(), @today.getMonth(), @today.getDate()

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
		#console.log @model
		data =
			"name": @model.get("experiment").name
			"time": @formatDate()

		$(@el).html(@template(data))
		@image = $(@el).find(".image")
		@hand = $(@el).find(".hand")
		return this

	formatTime: (time) ->
		timeZoneDiff = @today.getTimezoneOffset()
		ampm = ""
		hours = parseInt(time.split(":")[0])
		minutes = parseInt(time.split(":")[1])
		aggregateToMinutes = ((hours * 60) + minutes) - timeZoneDiff
		hours = parseInt(aggregateToMinutes / 60)
		minutes = aggregateToMinutes % 60
		if hours >= 12 then ampm = "PM" else ampm = "AM"
		if hours > 12
			hours = hours - 12
		return "#{hours}:#{minutes}#{ampm}"

	formatDate: () ->
		val = @model.get("experiment").completed_at || @model.get("experiment").created_at
		timeVar = val.split("T")
		date = timeVar[0]
		time = timeVar[1].substr(0,5)
		@year = @getYear(date)
		@month = @getMonth(date)
		@date = @getDate(date)
		experimentTimeStamp = Date.parse("#{@year}/#{@month}/#{@date}")
		
		if @model.get("experiment").completed_at

			if experimentTimeStamp is @todayTimeStamp
				return "RUN TODAY, #{@formatTime(time)}"
			else if @todayTimeStamp - experimentTimeStamp is 86400000 #86400000 no of seconds in a day
				return "RUN YESTERDAY, #{@formatTime(time)}"
			return "RUN #{@getMonth(date, "text")} #{@getDate(date)}, #{@formatTime(time)}"

		else if @model.get("experiment").created_at

			if experimentTimeStamp is @todayTimeStamp
				return "CREATED TODAY, #{@formatTime(time)}"
			else if @todayTimeStamp - experimentTimeStamp is 86400000 #86400000 no of seconds in a day
				return "CREATED YESTERDAY, #{@formatTime(time)}"
			return "CREATED #{@getMonth(date, "text")} #{@getDate(date)}, #{@formatTime(time)}"


	getMonth: (date, text) ->
		month = parseInt(date.substr(5,2))
		if text then return @Months[month - 1] else return month - 1

	getDate: (date) ->
		return parseInt(date.substr(8,2))

	getYear: (date) ->
		return parseInt(date.substr(0,4))

	deleteExperimentConfirm: () ->
		# Shows a confirm box to delete
		if @readyToDelete is true
			$(@el).find(".confirm-box").show("fast")

	dontDelete: () ->
		$(@el).find(".confirm-box").hide("slow")

	yesDelete: () ->
		#@console.log @
		@model.perish()
		callBack = () -> # Defining a local call back to pass to animate
			@.remove()
			$(".hand:last").hide("slow")

		action = 
			height: "0px"

		$(@.el).animate(action, 500, callBack)
		





