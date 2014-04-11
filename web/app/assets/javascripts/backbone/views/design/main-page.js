ChaiBioTech.Views.Design = ChaiBioTech.Views.Design || {} ;

ChaiBioTech.Views.Design.Index_view = Backbone.View.extend({

	template: JST["backbone/templates/design/main-page"],

	events: {
		"click li": "sideBarHandler"
	},
	
	intialize: function() {

	},

	sideBarHandler: function(e) {
		$(this.el).find("li.active").removeClass("active");
		$(e.currentTarget).addClass("active");
	},

	render: function() {
		$(this.el).html(this.template());
		return this;
	}

});