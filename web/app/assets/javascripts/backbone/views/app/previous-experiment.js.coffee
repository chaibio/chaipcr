ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

class ChaiBioTech.app.Views.experiment extends Backbone.View

	template: JST["backbone/templates/app/previous-experiment"]
	className: "individual-experiment"

	initialize: () ->

	
	render: () ->
		data =
			"name": @model.get("experiment").name

		$(@el).html(@template(data))
		return this



