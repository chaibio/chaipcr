// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//= require jquery-1.10.1.min
//= require jquery-ui.min
//= require underscore
//= require backbone
//= require backbone_datalink
//= require bootstrap.min
//= require bootstrap-editable.min
//= require raphael
//= require g.raphael
//= require g.line
//= require rails
//= require chaipcr
//= require backbone/ChaiBioTech
//= require backbone/Constants


$(function () {
	window.router = new ChaiBioTech.Routers.DesignRouter({});
   	window.touchScreenRouter = new ChaiBioTech.Routers.touchScreen({});
   	window.logScreenRouter = new ChaiBioTech.Routers.temperatureLog({});
   	window.appRouter = new ChaiBioTech.Routers.appRouter({});
   	Backbone.history.start();
   	window.location = "#/login"; //Temporary to bypass. Disable this to test add new experiments.
});
