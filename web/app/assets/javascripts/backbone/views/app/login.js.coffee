ChaiBioTech.Views.app = ChaiBioTech.Views.app || {}

class ChaiBioTech.Views.app.login extends Backbone.View

	template: JST["backbone/templates/app/login-page"]
	loggedIn: false
	events:
		"click #login-button": "loginCheck"

	initialize: () ->
		console.log @template

	render: () ->
		$(@el).html(@template())
		return @

	loginCheck: () ->
		/// here check for login details ///
		/// Just for now ///
		@loggedIn = true 
		if @loggedIn
			/// Show experiments ///
			@loadExperiments();
		else
			///Show Error message for wrong credentialas ///
			console.log "wrong creds"

	loadExperiments: () ->
		$("#container").html("Loading .... !")




