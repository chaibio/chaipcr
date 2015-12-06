(function () {

  App.service('Experiment', [
   '$resource', '$http', 'host', function ($resource, $http, host) {
     var currentExperiment, self;
     currentExperiment = null;
     self = $resource('/experiments/:id', {
       id: '@id'
     }, {
       'update': {
         method: 'PUT'
       }
     });
     self.setCurrentExperiment = function(exp) {
       return currentExperiment = exp;
     };
     self.getCurrentExperiment = function() {
       return currentExperiment;
     };
     self.getTemperatureData = function(expId, opts) {
       if (opts == null) {
         opts = {};
       }
       opts.starttime = opts.starttime || 0;
       opts.resolution = opts.resolution || 1000;
       return $http.get("/experiments/" + expId + "/temperature_data", {
         params: {
           starttime: opts.starttime,
           endtime: opts.endtime,
           resolution: opts.resolution
         }
       });
     };
     self.getFluorescenceData = function(expId) {
       return $http.get("/experiments/" + expId + "/fluorescence_data");
     };
     self.duplicate = function(expId, data) {
       return $http.post("/experiments/" + expId + "/copy", data);
     };
     self.startExperiment = function(expId) {
       return $http.post(host + ":8000/control/start", {
         experiment_id: expId
       });
     };
     self.resumeExperiment = function() {
       return $http.post(host + ":8000/control/resume");
     };
     self.stopExperiment = function() {
       return $http.post(host + ":8000/control/stop");
     };
     self.analyze = function (id) {
       return $http.get("/experiments/"+id+"/analyze");
     };
     return self;
   }
  ]);

 }) ();