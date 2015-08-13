var status = require('./status.json');
var statuses = ['Idle', 'LidHeating', 'Running', 'Paused', 'Complete'];

var http = require('http');

var i = 0;

var update = function () {
  i ++;
  if (i === statuses.length) i = 0;
  setTimeout(update, 5000);
};

update();

var app = http.createServer(function(req,res){

    status.experimentController.machine.state = statuses[i];

    res.setHeader('Content-Type', 'text/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization');
    res.statusCode = 200;
    res.end(JSON.stringify(status));
});

app.listen(8000);

console.log('Listening on http://localhost:8000');
