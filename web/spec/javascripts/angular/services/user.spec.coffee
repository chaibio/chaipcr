describe 'User Service', ->

  beforeEach ->

    module 'ChaiBioTech'

    inject ($injector) ->
      @httpBackend = $injector.get '$httpBackend'
      @User = $injector.get 'User'
      @userMock =
        id: 1
        email: 'pitogo.adones@gmail.com'

  it 'should fetch users', ->
    @httpBackend.expectGET('/users').respond [@userMock]
    @User.fetch().then (users) =>
      expect(users).toEqual [@userMock]

    @httpBackend.flush()

  it 'should save user', ->
    @httpBackend.expectPOST('/users').respond user: @userMock
    @User.save(@userMock).then (user) =>
      expect(user).toEqual @userMock

    @httpBackend.flush()

  it 'should delete user', ->
    @httpBackend.expectDELETE("/users/#{@userMock.id}").respond 200
    @User.remove(@userMock.id)
    @httpBackend.flush()