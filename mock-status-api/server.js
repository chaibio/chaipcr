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

var toUp = true;
setInterval(function () {
  toUp = (Math.random() > 0.5)? true: false;
}, 3000);

var stable = true;
setInterval(function () {
  stable = (Math.random() > 0.5)? true: false;
}, 2000);

function makeNewLog () {
  return {
    elapsed_time: (Math.floor(lastLog.elapsed_time/1000) * 1000) + 1000 + Math.round(Math.random() * 10),
    lid_temp: stable? lastLog.lid_temp : Math.random() + lastLog.lid_temp + (!toUp && lastLog.lid_temp > 0 ? -Math.random() : Math.random()),
    heat_block_zone_1_temp: stable? lastLog.heat_block_zone_1_temp : Math.random() + lastLog.heat_block_zone_1_temp + (!toUp && lastLog.heat_block_zone_1_temp > 0 ? -1 : 1),
    heat_block_zone_2_temp: stable? lastLog.heat_block_zone_2_temp : Math.random() + lastLog.heat_block_zone_2_temp + (!toUp && lastLog.heat_block_zone_2_temp > 0 ? -1 : 1),
  };
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

  function insert () {
    var newLog = makeNewLog();

    var id = experiment_id;
    var elapsed_time = newLog.elapsed_time;
    var lid_temp = newLog.lid_temp;
    var heat_block_zone_1_temp = newLog.heat_block_zone_1_temp;
    var heat_block_zone_2_temp = newLog.heat_block_zone_2_temp;

    insertLog(id, elapsed_time, lid_temp ,heat_block_zone_1_temp, heat_block_zone_2_temp, function () {
      lastElapsedTime = elapsed_time;
      lastLog = {
        experiment_id: id,
        elapsed_time: elapsed_time,
        lid_temp: lid_temp,
        heat_block_zone_1_temp: heat_block_zone_1_temp,
        heat_block_zone_2_temp: heat_block_zone_2_temp
      };
      cb();
    });
  }


  if(!lastLog) {
    insertLog(experiment_id, 0, 0, 0);
    lastLog = {
      experiment_id: 0,
      elapsed_time: 0,
      lid_temp: 0,
      heat_block_zone_1_temp: 0,
      heat_block_zone_2_temp: 0
    };
    insert();
  }
  else {
    insert();
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

    setTimeout(function () {
      data.optics.collectData = true;
      data.experimentController.expriment.step.name = "Step 2";
      data.experimentController.expriment.step.number = "2";
    }, 3000);

    setTimeout(function () {
      data.optics.collectData = true;
      data.experimentController.expriment.step.name = "Step 2";
      data.experimentController.expriment.step.number = "2";
      setTimeout(function () {
        data.experimentController.expriment.stage.cycle = "40";
      }, 3000);
    }, 5000);

  }, 3000);

  setTimeout(stop, 1000 * 60 * 15);

  res.send(true);
});

function stop () {
  completeExperiment(experiment_id);
  data = status_idle;
  lastLog = null;
  clearTimeout(intrvl);
}

app.post('/control/stop', function (req, res, next) {
  stop();
  res.send(true);
});

app.listen(8000);