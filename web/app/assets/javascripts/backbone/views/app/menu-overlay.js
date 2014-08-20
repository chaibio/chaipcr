ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverLay = Backbone.View.extend({

	className: "menu-overlay-container",

	template: JST["backbone/templates/app/menu-overlay"],	
	
	initialize: function() {
		this.fixMenu();
		this.expInProgress();
	},

	fixMenu: function() {
		this.menu = new ChaiBioTech.app.Views.menuOverlayMenu();
	},

	expInProgress: function() {
		this.experimentInProgress = new ChaiBioTech.app.Views.experimentInProgress({
			"wholeWidth": 350
		});
	},

	render: function() {
		$(this.el).html(this.template());
		$(this.el).find(".left-side").prepend(this.menu.render().el);
		$(this.el).find(".experiment-in-progress-container").append(this.experimentInProgress.render().el);
		return this;
	}
});