ChaiBioTech.Views.touchScreen = ChaiBioTech.Views.touchScreen || {} ;

ChaiBioTech.Views.touchScreen.homePage = Backbone.View.extend({
	
	template: JST["backbone/templates/touchscreen/main"],
	events: {
		"click #goButton": "runExp"
	},

	initialize: function() {
		console.log(this);
	},

	runExp: function() {
		
	},

	populateList: function() {
		that = this;
		classes = ["success", "info", "warning", "danger"];
		list_group = $(that.el).find(".list-group");
		_.each(this.collection.models, function(experiment, index) {
			listItem = new ChaiBioTech.Views.touchScreen.listItem({
				model: experiment,
				myClass: classes[index % 4]
			});
			list_group.append(listItem.render().el);
		});
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}
});