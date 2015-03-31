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


	attributes = {
      "tab 1": {
        fields: {
          Volume: {
            id:       'volume',
            name:     'Volume',
            type:     'numeric',
            placeholder: "Volume",

            units: {
              1: "m/s",
              2: "Nm"
            }
          },

          Polymerase: {
            id: 'pol',
            name: 'Polymerase',
            type: 'multiselect',
            placeHolder: "Polymerase",

            options: {
                'Taq 1':  {
                      id:   '234',
                      name: 'Taq 1'
                  },
                'Taq 2':  {
                      id:   '123',
                      name: 'Taq 2'
                  }
            }
          },

          master_mix: {
            id:       'volume',
            name:     'master mix concentration factor',
            type:     'text',
            units:    'volume_units'
          },

          Amplicons: {
            id:       'volume',
            name:     'Amplicons',
            type:     'boolean',
            units:    'volume_units'
          },

          Buffer: {
            id:       'volume',
            name:     'Buffer',
            type:     'numeric',

            units: {
              1: "m/s",
              2: "Nm"
            }
          },

          Volume2: {
            id:       'volume2',
            name:     'Volume2',
            type:     'numeric',
            placeholder: "Volume",

            units: {
              1: "m/s",
              2: "Nm"
            }
          }
        },
      },

      "tab 2": {
        fields: {
          dNTPs : {
            id: 'poly',
            name: 'dNTPs',
            type: 'multiselect',

            options: {
                'Taq 1':  {
                      id:   '234',
                      name: 'Taq 1'
                  },
                'Taq 2':  {
                      id:   '123',
                      name: 'Taq 2'
                  }
            }
          }
        }
      },

      "tab 3": {
        fields: {
          Volume3: {
            id:       'volume3',
            name:     'Volume3',
            type:     'numeric',

            units: {
              1: "m/s",
              2: "Nm"
            }
          },

          Polymerase: {
            id: 'polo',
            name: 'Polymerase',
            type: 'multiselect',

            options: {
                'Taq 1':  {
                      id:   '234',
                      name: 'Taq 1'
                  },
                'Taq 2':  {
                      id:   '123',
                      name: 'Taq 2'
                  }
            }
          }
        }
      },

      "tab 4": {

        fields: {
          Volume: {
            id:       'volume',
            name:     'Volume',
            type:     'numeric'
          },

          dNTPs : {
            id: 'poloo',
            name: 'dNTPs',
            type: 'multiselect',

            options: {
                'Taq 1':  {
                      id:   '234',
                      name: 'Taq 1'
                  },
                'Taq 2':  {
                      id:   '123',
                      name: 'Taq 2'
                  }
            }
          }
        }
      }
    }


	logMeIn: () ->
		@loginScreen = new ChaiBioTech.app.Views.login
		$("#container").html(@loginScreen.render().el)

	plateSetup: (id) ->
		@plateSetup = new ChaiBioTech.app.Views.plateSetup
		$("#container").html(@plateSetup.render().el);
		$("#container").find(".plate-setup-container").plateLayOut({
			value: 10
			attributes: attributes
		});

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
