ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.deviceRunExp = Backbone.View.extend({

  template: JST["backbone/templates/800x480/run/device-run-components"],

  className: "device-run-exp-container",

  initialize: function() {
    this.addStripes();
    this.addExpName();
    this.addButtons();
    this.manageMiddle();
    this.addManageExpInProgress();
  },

  addManageExpInProgress: function() {
    this.expInProgress = new ChaiBioTech.app.Views.deviceExpInProgress({
      model: this
    });
  },

  manageMiddle: function() {
    this.middleSection = new ChaiBioTech.app.Views.deviceRunMiddleSection({
      model: this.model
    })
  },

  addStripes: function() {
    this.stripes = new ChaiBioTech.app.Views.deviceRunStripes({
      model: this.model
    });
  },

  addExpName: function() {
    this.expName = new ChaiBioTech.app.Views.deviceRunExpName({
      model: this.model
    });
  },

  addButtons: function() {
    this.buttons = new ChaiBioTech.app.Views.deviceRunButtons({
      model: this.model
    })
  },

  render: function() {
    $(this.el).html(this.template());
    $(this.el).find(".device-run-top").append(this.stripes.render().el);
    $(this.el).find(".device-run-top").append(this.expName.render().el);
    $(this.el).find(".device-run-top").append(this.buttons.render().el);
    $(this.el).find(".device-run-middle").append(this.middleSection.render().el);
    var data = {
      "stepNo": 0,
      "stageNo": 0,
      "status": "",
      "time": ""
    };
    $(this.el).find(".device-run-bottom").append(this.expInProgress.render(data).el);
    return this;
  }
});
