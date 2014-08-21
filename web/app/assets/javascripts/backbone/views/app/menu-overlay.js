ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverLay = Backbone.View.extend({

	className: "menu-overlay-container",

	template: JST["backbone/templates/app/menu-overlay"],	
	
	initialize: function() {
		this.fixMenu();
		this.expInProgress();
		this.addExpNameSection();
		this.addExpOptions();
	},

	fixMenu: function() {
		this.menu = new ChaiBioTech.app.Views.menuOverlayMenu();
	},

	expInProgress: function() {
		this.experimentInProgress = new ChaiBioTech.app.Views.experimentInProgress({
			"wholeWidth": 350
		});
	},

	addExpNameSection: function() {
		this.menuOverlayTitle = new ChaiBioTech.app.Views.menuOverlayTitle();
	},

	addExpOptions: function() {
		this.menuOverlayOptions = new ChaiBioTech.app.Views.menuOverlayOptions();
	},

	render: function() {
		$(this.el).html(this.template());
		$(this.el).find(".left-side").prepend(this.menu.render().el);
		$(this.el).find(".experiment-in-progress-container").append(this.experimentInProgress.render().el);
		$(this.el).find(".right-side").append(this.menuOverlayTitle.render().el);
		return this;
	}
});