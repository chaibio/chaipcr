var express = require('express');
var app = express();

app.use(function (req, res, next) {
  res.setHeader('Content-Type', 'text/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization');
  next();
});

function rawBody(req, res, next) {
  var body;
  req.setEncoding('utf8');
  body = '';
  req.on('data', function(chunk) {
    body += chunk;
  });
  req.on('end', function(){
    if (body !== '') req.payload = JSON.parse(body);
    next();
  });
}

app.use(rawBody);

var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : '',
  database : 'chaipcr'
});

var status_idle = require('./status-idle.json');
var status_lid_heating = require('./status-lid-heating.json');
var status_running = require('./status-running.json');
var STATUSES = ['Idle', 'LidHeating', 'Running', 'Paused', 'Complete'];
var experiment_id = null;
var lastLog = null;
var data = status_idle;
var intrvl = null;
var lastElapsedTime = null;

function getLastLog (cb) {
  cb = cb || function () {};
  connection.query('SELECT * FROM `temperature_logs` ORDER BY `elapsed_time` ASC', function (err, rows, fields) {
    if (err) throw err;
    lastLog = rows.length > 0 ? rows[rows.length-1] : {experiment_id: null, elapsed_time: 14, lid_temp:0, heat_block_zone_1_temp:0, heat_block_zone_2_temp: 0};
    lastElapsedTime = lastLog.elapsed_time;
    cb(lastLog);
  });
}

function insertLog (id, elapsed_time, lid_temp, heat_block_zone_1_temp, heat_block_zone_2_temp, cb) {
  cb = cb || function () {};
  connection.query("INSERT INTO `chaipcr`.`temperature_logs` (`experiment_id`, `elapsed_time`, `lid_temp`, `heat_block_zone_1_temp`, `heat_block_zone_2_temp`) VALUES ('"+id+"', '"+elapsed_time+"', '"+lid_temp+"', '"+heat_block_zone_1_temp+"', '"+heat_block_zone_2_temp+"')", function (err, rows, fields) {
    if (err) throw err;
    cb(err, rows, fields);
  });
}

function makeTemperature () {
  return (Math.random() * 5).toFixed(2)*1 + 50;
}

function startExperiment (id, cb) {
  cb = cb || function () {};
  connection.query("UPDATE `chaipcr`.`experiments` SET `started_at` = '2015-09-02 00:00:00' WHERE `experiments`.`id` = "+id, cb);
}

function completeExperiment(id, cb) {
  cb = cb || function () {};
  connection.query("UPDATE `chaipcr`.`experiments` SET `completed_at` = '2015-09-02 00:00:00', `completion_status` = 'aborted' WHERE `experiments`.`id` = "+id, cb);
}

function incrementLog (cb) {
  cb = cb || function () {};

  if(!experiment_id) throw new Error("Experiment ID can't be empty.");

  function insert (lastET) {
    var id = experiment_id;
    var elapsed_time = lastET*1 + 1000;
    var lid_temp = makeTemperature();
    var heat_block_zone_1_temp = makeTemperature();
    var heat_block_zone_2_temp = makeTemperature();

    insertLog(id, elapsed_time, lid_temp ,heat_block_zone_1_temp, heat_block_zone_2_temp, function () {
      insertLog(id, elapsed_time+14, lid_temp, heat_block_zone_1_temp, heat_block_zone_2_temp,function (err, rows, fields) {
        lastElapsedTime = elapsed_time;
        cb();
      });
    });
  }


  if(!lastElapsedTime) {
    getLastLog(function (dbLastLog) {
      lastElapsedTime = dbLastLog.elapsed_time;
      insert(lastElapsedTime);
    });
  }
  else {
    insert(lastElapsedTime);
  }
}

function autoupdateLogs() {
  incrementLog();
  intrvl = setTimeout(autoupdateLogs, 1000);
}

app.get('/status', function (req, res, next) {
  res.send(data);
});

app.post('/control/start', function (req, res, next) {
  data = status_lid_heating;
  data.experimentController.expriment.id = req.payload.experimentId;
  startExperiment(req.payload.experimentId);
  experiment_id = req.payload.experimentId;
  setTimeout(function () {
    data.experimentController.machine.state = 'Running';
    data.experimentController.machine.thermal_state = 'Holding';
    autoupdateLogs();
  }, 3000);

  setTimeout(stop, 1000 * 15);

  res.send(true);
});

function stop () {
  completeExperiment(experiment_id);
  data = status_idle;
  clearTimeout(intrvl);
}

app.post('/control/stop', function (req, res, next) {
  stop();
  res.send(true);
});

app.listen(8000);