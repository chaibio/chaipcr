ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.login extends Backbone.View

	template: JST["backbone/templates/app/login-page"]
	loggedIn: false
	events:
		"click #login-button": "loginCheck"

	initialize: () ->
		#console.log @template

	render: () ->
		$(@el).html(@template())
		return this

	loginCheck: () ->
		# Here check for login details
		# Just for now
		@loggedIn = true 
		if @loggedIn
			# Show experiments
			location.href = "#/home"
			@user = ($ "#user").val().replace(/[^a-zA-Z ]/g, "")
		else
			# Show Error message for wrong credentialas
			console.log "wrong creds"

		




