describe("Testing ExperimentLoader service", function() {

   var _ExperimentLoader, _Experiment, _$q, _$stateParams, _$rootScope, _$http, $httpBackend;

   beforeEach(function() {
        
        var meth = {
            
        };
        module('ChaiBioTech', function($provide) {
            //$provide.value('Experiment',  meth);
        });

        inject(function($injector) {
            $httpBackend = $injector.get('$httpBackend');
            $httpBackend.whenGET("http://localhost:8000/status").respond("NOTHING");
            $httpBackend.whenGET("http://localhost:8000/network/wlan").respond({
                data: {
                    state: {
                        macAddress: "125",
                        status: {

                        }
                    }
                }
            });
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _$q = $injector.get('$q');
            _$stateParams = $injector.get('$stateParams');
            _$rootScope = $injector.get('$rootScope');
            _$http = $injector.get('$http');
            _Experiment = $injector.get('Experiment');
        });

        
            
    });

    /*it("It should test getExperiment method", function() {
        //console.log(_Experiment.get().then(), "Okay");
        //spyOn(_Experiment, "get");
        _Experiment.get = function() {
            var del = _$q.defer();
            del.resolve({experiment: {
                id: 1
            }});
            return del.promise;
        };

        _$stateParams.id = 10;
        _ExperimentLoader.getExperiment();
        //expect(_Experiment.get).toHaveBeenCalled();
   });*/

   it("It should test getExperiment method", function() {
       _$stateParams.id = 10;
        
        $httpBackend.expectGET('/experiments/10').respond({
            experiment: {
                id: 10
            }
        });
        _ExperimentLoader.getExperiment();

        $httpBackend.flush();
        expect(_ExperimentLoader.protocol.id).toEqual(10);

   });
});