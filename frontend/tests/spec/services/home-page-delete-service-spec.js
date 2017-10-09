describe("Testing HomePageDelete", function() {

    var _HomePageDelete, _$window;
    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            mockCommonServices($provide);
        });

        inject(function($injector) {
            _HomePageDelete = $injector.get('HomePageDelete');
            _$window = $injector.get('$window');
        });
    });

    it("It should test click event", function() {

        spyOn(_HomePageDelete, "disableActiveDelete");
        _HomePageDelete.activeDelete = true;
        angular.element(_$window).click();
        expect(_HomePageDelete.disableActiveDelete).toHaveBeenCalled();
    });

    it("It should test click event when activeDelete = false", function() {

        spyOn(_HomePageDelete, "disableActiveDelete");
        _HomePageDelete.activeDelete = false;
        angular.element(_$window).click();
        expect(_HomePageDelete.disableActiveDelete).not.toHaveBeenCalled();
    });

    it("It should deactiveate method", function() {

        _HomePageDelete.activeDelete = {
            $id: 12
        };
        var currentScope = {
            $id: 10,
        };

        _HomePageDelete.deactiveate(currentScope);

        expect(_HomePageDelete.activeDelete.deleteClicked).toEqual(false);
    });

    it("It should deactiveate method", function() {

        _HomePageDelete.activeDelete = false;
        var currentScope = {
            $id: 10,
        };

        _HomePageDelete.deactiveate(currentScope);

        expect(_HomePageDelete.activeDelete.deleteClicked).not.toBeDefined();
    });

    it("It should deactiveate method when currentScope.$id === this.activeDelete.$id", function() {

        _HomePageDelete.activeDelete = {
            $id: 10
        };
        var currentScope = {
            $id: 10,
        };

        _HomePageDelete.deactiveate(currentScope);

        expect(_HomePageDelete.activeDelete).toEqual(false);
        expect(_HomePageDelete.activeDeleteElem).toEqual(false);
    });

    it("It should disableActiveDelete method", function() {
        _HomePageDelete.activeDelete = {};
        _HomePageDelete.disableActiveDelete();
        expect(_HomePageDelete.activeDelete.deleteClicked).toEqual(false);
    });
});