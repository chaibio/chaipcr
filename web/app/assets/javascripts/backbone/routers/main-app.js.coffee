class ChaiBioTech.Routers.appRouter extends Backbone.Router

	loginScreen: {}

	homePage: {}

	iniitialize: () ->
		#console.log "wow";

	routes:
		"login": "logMeIn"
		"home": "loadHome"
		"edit-exp-menu/:id": "editExp" # Remember this is the one for bringing up menu overlay
		"edit-stage-step/:id": "loadStepStage"
		"run-exp/:id": "runExp",
		"plate-setup/:id": "plateSetup"

	logMeIn: () ->
		@loginScreen = new ChaiBioTech.app.Views.login
		$("#container").html(@loginScreen.render().el)

	plateSetup: (id) ->
		console.log "wooo", id
	
	loadHome: () ->
		if @loggedIn() is true
			data =
			"user": @loginScreen.user

			@homePage = new ChaiBioTech.app.Views.homePage data
			$("#container").html(@homePage.render().el)
		else
			location.href = "#/login"

	loggedIn: () ->
		if @loginScreen.loggedIn
			return yes
		return no

	editExp: (id) ->
		that = this;
		callback = () ->
			that.menuOverLay = new ChaiBioTech.app.Views.menuOverLay({
				model: ExpModel
			});
			$("#container").append(that.menuOverLay.render().el)

		ExpModel = new ChaiBioTech.Models.Experiment({"id": id, "callback": callback});

	runExp: (id) ->
		that = this;
		callback = () ->
			that.runExpView = new ChaiBioTech.app.Views.runExperiment({
					model: ExpModel
			});
			$("#container").html(that.runExpView.render().el);

		ExpModel = new ChaiBioTech.Models.Experiment({"id": id, "callback": callback});

	loadStepStage: (id) ->
		that = this;
		# Sending it as a callback, So that the canvas is created just after model is complete;
		callback = () ->
			that.fabricCanvas = new ChaiBioTech.app.Views.fabricCanvas(ExpModel, that);
			that.fabricCanvas.addStages().setDefaultWidthHeight().addinvisibleFooterToStep();

		ExpModel = new ChaiBioTech.Models.Experiment({"id": id, "callback": callback});
		@editStageStep = new ChaiBioTech.app.Views.editStageStep({
				model: ExpModel
			});
		$("#container").html(@editStageStep.render().el);
