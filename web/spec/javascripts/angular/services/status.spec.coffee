describe 'Status Service', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->

      @httpBackend = $injector.get '$httpBackend'
      @Status = $injector.get 'Status'

  it 'should fetch experiment progress status', ->
    @httpBackend.expect('GET', 'http://localhost:8000/status').respond {}
    spy = jasmine.createSpy()
    @Status.fetch(spy);
    @httpBackend.flush()
    expect(spy).toHaveBeenCalled()