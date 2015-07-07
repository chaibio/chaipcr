
var faker = require('faker');

function randomNumber () {
  return Math.floor(Math.random() * 100);
}

function Status() {

  var run_duration = 60 * randomNumber();
  var estimated_duration = run_duration + Math.round(run_duration*randomNumber()/100);

  this.experiment = {
    name: 'Experiment Name '+faker.name.firstName(),
    run_duration: run_duration,
    estimated_duration: estimated_duration,
    started_at: new Date(),
    stage: {
      id: randomNumber(),
      name: faker.company.companyName(),
      number: randomNumber(),
      cycle: randomNumber()
    },
    step: {
      id: randomNumber(),
      name: faker.company.companyName(),
      number: randomNumber()
    }
  };
}

var http = require('http');

var app = http.createServer(function(req,res){
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token');
    res.end(JSON.stringify(new Status()));
});
app.listen(8000);

console.log('Listening on http://localhost:8000');
