var userMock = {
  id: 1,
  name: 'Test'
}

function UserServiceMock() {
  this.getCurrent = function() {
    return {
      then: function(fn) {
        var res = {
          data: {
            user: userMock
          }
        }
        fn(res)
      }
    }
  }
}