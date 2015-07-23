var status = require('./status.json');
var statuses = ['Idle', 'LidHeating', 'Running', 'Paused', 'Complete'];

var http = require('http');

var app = http.createServer(function(req,res){

    var i = Math.round((statuses.length-1) * Math.random());

    status.experimentController.machine.state = statuses[i];

    res.setHeader('Content-Type', 'text/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token');
    res.end(JSON.stringify(status));
});
app.listen(8000);

console.log('Listening on http://localhost:8000');
