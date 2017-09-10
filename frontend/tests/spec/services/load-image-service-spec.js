describe("Testing loadImageService", function() {

    var _loadImageService;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            
        });

        inject(function($injector) {
            _loadImageService = $injector.get('loadImageService');
        });

        
    });

    it("It should test getImages method", function() {
       
        /*var imageArray = [{name: "image1"}, {name: "image2"}, {name: "image3"}];

        spyOn(_loadImageService, "getImagesMapCallback").and.returnValue(true);

        var returnVal = _loadImageService.getImages(imageArray);

        //expect(_loadImageService.getImagesMapCallback);
        */

    });
});