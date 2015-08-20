var status = require('./status.json');
var STATUSES = ['Idle', 'LidHeating', 'Running', 'Paused', 'Complete'];
status.experimentController.expriment.run_duration = 0;
status.experimentController.expriment.paused_duration = 3;
status.experimentController.expriment.estimated_duration = 20;

var i = 0;

var update = function () {
  var isRunning = i === 2;
  if(isRunning) {
    status.experimentController.expriment.run_duration += 1;

    if(status.experimentController.expriment.run_duration > status.experimentController.expriment.estimated_duration) {
      status.experimentController.expriment.run_duration = 0;
      isRunning = false;
    }
    else {
      setTimeout(update, 500);
    }
  }
  if (!isRunning) {
    i ++;
    if (i === STATUSES.length) i = 0;
    setTimeout(update, 5000);
  }
};

update();

var http = require('http');
var app = http.createServer(function(req,res){

    status.experimentController.machine.state = STATUSES[i];

    res.setHeader('Content-Type', 'text/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization');
    res.statusCode = 200;
    res.end(JSON.stringify(status));
});

app.listen(8000);

console.log('Listening on http://localhost:8000');
