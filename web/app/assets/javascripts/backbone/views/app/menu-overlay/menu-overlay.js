ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.menuOverLay = Backbone.View.extend({

	className: "menu-overlay-container",

	template: JST["backbone/templates/app/menu-overlay"],

	initialize: function() {
		this.fixMenu();
		this.expInProgress();
		this.addExpNameSection();
		this.addExpOptions();
		this.addExpOptionsContent();
	},

	fixMenu: function() {
		this.menu = new ChaiBioTech.app.Views.menuOverlayMenu({
			model: this.model
		});
	},

	expInProgress: function() {
		this.experimentInProgress = new ChaiBioTech.app.Views.experimentInProgress({
			"wholeWidth": 350
		});
	},

	addExpNameSection: function() {
		this.menuOverlayTitle = new ChaiBioTech.app.Views.menuOverlayTitle({
			model: this.model
		});
	},

	addExpOptions: function() {
		this.menuOverlayOptions = new ChaiBioTech.app.Views.menuOverlayOptions();
	},

	addExpOptionsContent: function() {
		this.menuOverlayOptionsContent = new ChaiBioTech.app.Views.menuOverlayOptionsContent();
	},

	render: function() {
		$(this.el).html(this.template());

		$(this.el).find(".left-side").prepend(this.menu.render().el);
		$(this.el).find(".menu-overlay-all-options").append(this.menuOverlayOptionsContent.render().el);
		$(this.el).find(".experiment-in-progress-container").append(this.experimentInProgress.render().el);
		$(this.el).find(".right-side").append(this.menuOverlayTitle.render().el);
		$(this.el).find(".right-side").append(this.menuOverlayOptions.render().el);
		
		return this;
	}
});
