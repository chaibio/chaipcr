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
//= require select2
//= require rails
//= require chaipcr
//= require fabric
//= require plate-layout
//= require backbone/ChaiBioTech
//= require backbone/Constants

// angularjs assets ==============
//= require angular
//= require angular-rails-templates
//= require angular/app
//= require angular/libs/perfect-scrollbar.jquery.min
//= require angular/libs/angular-perfect-scrollbar
//= require angular/libs/slider
//= require angular/libs/angular-ui-switch
//= require angular/libs/ui-bootstrap-custom-0.13.0
//= require angular/libs/ui-bootstrap-custom-tpls-0.13.0
//= require_tree ./angular/controllers
//= require_tree ./angular/services
//= require_tree ./angular/views

$(function () {
  //window.router = new ChaiBioTech.Routers.DesignRouter({});
  //window.touchScreenRouter = new ChaiBioTech.Routers.touchScreen({});
  //window.logScreenRouter = new ChaiBioTech.Routers.temperatureLog({});
  window.appRouter = new ChaiBioTech.Routers.appRouter({});
  window.deviceRouter = new ChaiBioTech.Routers.deviceRouter({});
  Backbone.history.start();
  //window.location = "#/800x480-home" // Enable this to get into device mode
  window.location = "#/login"; //Temporary to bypass. Disable this to test add new experiments.
});
