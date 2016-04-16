describe("see if its working", function() {

  beforeEach(module("ChaiBioTech"));

  beforeEach(module("canvasApp"));

  var Canvas;


  beforeEach(inject(function(_canvas_) {
    //console.log(_canvas_, "bimmmmmmm");
    Canvas = _canvas_;
  }));

  it("canvas.init should initiate values", function() {

    var model = {
      "protocol": {

      }
    };

    spyOn(Canvas, "loadImages");
    Canvas.init(model);

    expect(Canvas.editStageStatus).toBeFalsy();
    expect(Canvas.allCircles).toBeNull();

    expect(Canvas.images).toContain("gather-data.png");
    expect(Canvas.images).toContain("gather-data-image.png");
    expect(Canvas.images).toContain("pause.png");
    expect(Canvas.images).toContain("pause-middle.png");
    expect(Canvas.images).toContain("close.png");
    expect(Canvas.images).toContain("drag-footer-image.png");
    expect(Canvas.images).toContain("move-step-on.png");

    expect(Canvas.imageLocation).toEqual('/images/');
    expect(Canvas.canvas).not.toBeNull();
    expect(Canvas.moveLimit).toEqual(0);

    expect(Canvas.imageobjects).toEqual(jasmine.any(Object));
    expect(Canvas.dotCordiantes).toEqual(jasmine.any(Object));

    expect(Canvas.loadImages).toHaveBeenCalled();
  });
});
