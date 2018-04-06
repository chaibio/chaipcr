describe("Testing capsule directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _$compile = $injector.get('$compile');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _canvas = $injector.get('canvas');
            _$timeout = $injector.get('$timeout');
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10
            };
            var elem = angular.element('<capsule func="changeDeltaTime" delta="10" data="15"></capsule>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values, change in data", function() {

        
        spyOn(compiledScope, "configure").and.returnValue(true);
        
        compiledScope.delta = "true";
        compiledScope.data = 20;
        compiledScope.$digest();

        expect(compiledScope.originalValue).toEqual(20);
        expect(compiledScope.configure).toHaveBeenCalled();
    });

    it("It should test initial values and change in delta", function() {

        spyOn(compiledScope, "disable").and.returnValue(true);

        compiledScope.$apply(function() {
            compiledScope.delta = "false";
        });
        
        expect(compiledScope.disable).toHaveBeenCalled();
    });

    it("It should test clickCallback method", function() {

        compiledScope.$apply(function() {
            compiledScope.delta = "true";
        });

        //compiledScope.$digest();
        
        spyOn(compiledScope, "configure").and.returnValue(true);
        spyOn(compiledScope, "sendValue").and.returnValue(true);

        compiledScope.clickCallback();

        expect(compiledScope.configure).toHaveBeenCalled();
        expect(compiledScope.sendValue).toHaveBeenCalled();
    });

    it("It should test clickCallback method, originalValue is 0", function() {

        compiledScope.$apply(function() {
            compiledScope.delta = "true";
            compiledScope.originalValue = 0;
        });

        //compiledScope.$digest();
        
        spyOn(compiledScope, "configure").and.returnValue(true);
        spyOn(compiledScope, "sendValue").and.returnValue(true);
        spyOn(compiledScope, "justInverse").and.returnValue(true);

        compiledScope.clickCallback();

        expect(compiledScope.justInverse).toHaveBeenCalled();
        expect(compiledScope.configure).not.toHaveBeenCalled();
        expect(compiledScope.sendValue).not.toHaveBeenCalled();
    });
    
    it("It should test justInverse method", function() {

        spyOn(compiledScope, "positive").and.returnValue(true);
        spyOn($.fn, "position").and.returnValue({
            left: 0
        });

        compiledScope.justInverse();
        expect($.fn.position).toHaveBeenCalled();
        expect(compiledScope.positive).toHaveBeenCalled();
    });

    it("It should test justInverse method when left !== 0 ", function() {

        spyOn(compiledScope, "positive").and.returnValue(true);
        spyOn(compiledScope, "negative").and.returnValue(true);
        spyOn($.fn, "position").and.returnValue({
            left: 10
        });

        compiledScope.justInverse();
        expect($.fn.position).toHaveBeenCalled();
        expect(compiledScope.positive).not.toHaveBeenCalled();
        expect(compiledScope.negative).toHaveBeenCalled();
    });
    
    it("It should test positive method", function() {

        spyOn($.fn, "animate");
        spyOn($.fn, "parent").and.returnValue({
            parent: function() {
                return {
                    parent: function() {

                    },
                    css: function() {

                    }
                };
            },
            css: function() {

            }
        });
        spyOn($.fn, "css");
        spyOn($.fn, "find").and.returnValue({
            css: function() {
                
            }
        });

        compiledScope.positive();

        expect($.fn.animate).toHaveBeenCalled();
        expect($.fn.parent).toHaveBeenCalled();
        expect($.fn.css).not.toHaveBeenCalled();
        expect($.fn.find).toHaveBeenCalled();
    });

    it("It should test negative method", function() {

        spyOn($.fn, "animate");
        spyOn($.fn, "parent").and.returnValue({
            parent: function() {
                return {
                    parent: function() {

                    },
                    css: function() {

                    }
                };
            },
            css: function() {

            }
        });
        spyOn($.fn, "css");
        spyOn($.fn, "find").and.returnValue({
            css: function() {
                
            }
        });

        compiledScope.negative();

        expect($.fn.animate).toHaveBeenCalled();
        expect($.fn.parent).toHaveBeenCalled();
        expect($.fn.css).not.toHaveBeenCalled();
        expect($.fn.find).toHaveBeenCalled();
    });

    it("It should test disable method", function() {

        spyOn($.fn, "parent").and.returnValue({
            parent: function() {
                return {
                    parent: function() {

                    },
                    css: function() {

                    }
                };
            },
            css: function() {

            }
        });
        spyOn($.fn, "css");
        spyOn($.fn, "find").and.returnValue({
            css: function() {
                
            }
        });

        spyOn(compiledScope, "configurePlusMinus").and.returnValue(true);

        compiledScope.disable();

        expect(compiledScope.configurePlusMinus).toHaveBeenCalled();
        expect($.fn.parent).toHaveBeenCalled();
        expect($.fn.css).toHaveBeenCalled();
        expect($.fn.find).toHaveBeenCalled();
        expect($.fn.parent).toHaveBeenCalled();
    });

    it("It should test configure method", function() {

        spyOn(compiledScope, "negative").and.returnValue(true);
        spyOn(compiledScope, "positive").and.returnValue(true);

        compiledScope.configure();

        expect(compiledScope.positive).toHaveBeenCalled();
        expect(compiledScope.negative).not.toHaveBeenCalled();

    });

    it("It should test configure method when originalValue <= 0", function() {

        spyOn(compiledScope, "negative").and.returnValue(true);
        spyOn(compiledScope, "positive").and.returnValue(true);

        compiledScope.$apply(function() {
            compiledScope.originalValue = -3;
        });

        compiledScope.configure();

        expect(compiledScope.positive).not.toHaveBeenCalled();
        expect(compiledScope.negative).toHaveBeenCalled();

    });

    it("It should test sendValue method", function() {

        _ExperimentLoader.changeDeltaTime = function() {
            return {
                then: function(callback) {
                    var data = {};
                    callback(data);
                }
            };
        };

        compiledScope.$apply(function() {
            compiledScope.fun = "changeDeltaTime";
        });
        
        spyOn(compiledScope, "$apply").and.callThrough();

        spyOn(_ExperimentLoader, "changeDeltaTime").and.callThrough();

        compiledScope.sendValue();

        expect(compiledScope.$apply).toHaveBeenCalled();
        expect(_ExperimentLoader.changeDeltaTime).toHaveBeenCalled();
    });

});