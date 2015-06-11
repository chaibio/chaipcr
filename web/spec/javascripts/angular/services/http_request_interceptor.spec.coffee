describe 'httpRequestInterceptor Service', ->

  csrf ='test-csrf-string'

  $window = $: ->
    attr: -> csrf

  beforeEach ->

    module 'ChaiBioTech'

    module ($provide) ->
      $provide.value '$window', $window
      return

    inject ($injector) ->

      @httpBackend = $injector.get '$httpBackend'
      @httpRequestInterceptor = $injector.get 'httpRequestInterceptor'

  it 'should append csrf meta to header', ->
    config = headers: {}
    config = @httpRequestInterceptor.request(config)
    expect(config.headers['X-CSRF-Token']).toBe csrf
