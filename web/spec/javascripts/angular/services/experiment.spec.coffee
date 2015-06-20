describe 'Experiment Service', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->
      @Experiment = $injector.get 'Experiment'
      @httpBackend = $injector.get '$httpBackend'

  it 'should be instance of angular resource', ->
    expect(@Experiment.query).toEqual jasmine.any Function
    expect(@Experiment.get).toEqual jasmine.any Function

    newExp = new @Experiment()
    expect(newExp.$save).toEqual jasmine.any Function
    expect(newExp.$delete).toEqual jasmine.any Function
    expect(newExp.$remove).toEqual jasmine.any Function

  it 'should have update function', ->
    exp = id: 1
    @httpBackend.expect('PUT', "/experiments/#{exp.id}").respond 200
    @Experiment.update(exp)
    @httpBackend.flush()

  it 'should get experiment\'s temperature data', ->
    opts =
      starttime: 0
      endtime: null
      resolution: 1000

    expId = 3

    @httpBackend
    .expect('GET', "/experiments/#{expId}/temperature_data?resolution=#{opts.resolution}&starttime=#{opts.starttime}")
    .respond []

    spy = jasmine.createSpy()

    @Experiment.getTemperatureData(expId, opts).success spy
    @httpBackend.flush()
    expect(spy).toHaveBeenCalled()
