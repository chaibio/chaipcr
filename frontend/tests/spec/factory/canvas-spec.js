describe("Testing canvas.js", function() {

  beforeEach(module("ChaiBioTech"));

  beforeEach(module("canvasApp"));

  var Canvas;

  // Here 'Canvas' refer to the applications canvas area and 'canvas' refers actuall fabricjs canvas.
  beforeEach(inject(function(canvas) {
    //console.log(_canvas_, "bimmmmmmm");
    //console.log(canvas.init);
    var model = {
      "protocol": {

      }
    };
    
    Canvas = canvas;
    spyOn(Canvas, "loadImages");
    Canvas.init(model);


  }));

  it("canvas.init should initiate values", function() {
    
    expect(Canvas.editStageStatus).toBeFalsy();
    expect(Canvas.allCircles).toBeNull();

    expect(Canvas.images).toContain("gather-data.png");
    expect(Canvas.images).toContain("gather-data-image.png");
    expect(Canvas.images).toContain("pause.png");
    expect(Canvas.images).toContain("pause-middle.png");
    expect(Canvas.images).toContain("drag-footer-image.png");
    expect(Canvas.images).toContain("move-step-on.png");

    expect(Canvas.imageLocation).toEqual('/images/');
    expect(Canvas.canvas).not.toBeNull();
    expect(Canvas.moveLimit).toEqual(0);

    expect(Canvas.imageobjects).toEqual(jasmine.any(Object));
    expect(Canvas.dotCordiantes).toEqual(jasmine.any(Object));

    expect(Canvas.loadImages).toHaveBeenCalled();
  });

  it("setDefaultWidthHeight method should set the width of the canvas", function() {

    console.log(Canvas.setDefaultWidthHeight);

    spyOn(Canvas.canvas, "setHeight");
    spyOn(Canvas.canvas, "renderAll");
    spyOn(Canvas.canvas, "setWidth");

    Canvas.setDefaultWidthHeight();
    expect(Canvas.canvas.setHeight).toHaveBeenCalledWith(400);
    expect(Canvas.canvas.renderAll).toHaveBeenCalled();
    expect(Canvas.canvas.setWidth).toHaveBeenCalled();
    expect(Canvas.allStageViews.length).toEqual(jasmine.any(Number));
  });
});
