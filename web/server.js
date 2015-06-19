
var faker = require('faker');

function randomNumber () {
  return Math.floor(Math.random() * 100);
}

var status = {
  experiment: {
    run_duration: 60 * randomNumber(), // in secs
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
  }
};

var http = require('http');

var app = http.createServer(function(req,res){
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token');
    res.end(JSON.stringify(status));
});
app.listen(8000);

console.log('Listening on http://localhost:8000');
