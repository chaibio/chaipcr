window.ChaiBioTech.ngApp.service('loadImageService', [
    function() {
        /*
            we map an array which return promises, 
            and we look for promise.all 
        */

        this.getImages = function(imageArray) {

            var allPromises = imageArray.map(this.getImagesMapCallback, this);
            
            
            return new Promise(function(resolve, reject) {

                Promise.all(allPromises).then(function(values) {
                
                    var imageData = {};

                    values.forEach(function(data, index) {
                        imageData[data.iName] = data.image;
                    });
                    resolve(imageData);
                });
            });
        };
        
        this.getImagesMapCallback = function(imageName, index) {

            return new Promise(function(resolve, reject) {
                    
                fabric.Image.fromURL("/images/" + imageName, function(img) {
                    
                    data = {
                            iName: imageName,
                            image: img
                        };
                    resolve(data);
                });
            });
        };
        
    }
]);