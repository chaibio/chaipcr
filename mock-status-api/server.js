var express = require('express');
var bodyParser = require('body-parser');
var multer  =   require('multer');
var app = express();

var storage =   multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, './uploads');
  },
  filename: function (req, file, callback) {
    callback(null, file.fieldname);
  }
});
var upload = multer({ dest : './uploads'}).single('upgradefile');

app.use(bodyParser.json({limit: '50gb'}));
app.use(bodyParser.urlencoded({ extended: true }));

app.use(function (req, res, next) {
  res.setHeader('Content-Type', 'text/json');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', "PUT, GET, POST, DELETE, OPTIONS");
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With, X-Prototype-Version, X-CSRF-Token, Content-Type, Authorization');
  next();
});


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
var network = require('./network.json');
var wifi_networks = require('./wifi-networks.json');
var device = require('./device.json');
var ethernet = require('./ethernet.json');
var STATUSES = ['idle', 'lid_heating', 'running', 'paused', 'complete'];
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
    heat_block_zone_1_temp: stable? lastLog.heat_block_zone_1_temp : Math.random() + lastLog.heat_block_zone_1_temp + (!toUp && lastLog.heat_block_zone_1_temp > 0 ? -3 : 3),
    heat_block_zone_2_temp: stable? lastLog.heat_block_zone_2_temp : Math.random() + lastLog.heat_block_zone_2_temp + (!toUp && lastLog.heat_block_zone_2_temp > 0 ? -1 : 1),
  };
}

function startExperiment (id, cb) {
  cb = cb || function () {};
  connection.query("UPDATE `chaipcr`.`experiments` SET `started_at` = NOW() WHERE `experiments`.`id` = "+id, cb);
}

function completeExperiment(id, cb) {
  cb = cb || function () {};
  connection.query("UPDATE `chaipcr`.`experiments` SET `completed_at` = NOW(), `completion_status` = 'aborted' WHERE `experiments`.`id` = "+id, cb);
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
  if (data.experiment_controller.experiment) data.experiment_controller.experiment.run_duration = data.experiment_controller.experiment.run_duration*1+1;
  intrvl = setTimeout(autoupdateLogs, 1000);
}

var defaultSelected = {
  "interface": "wlan1",
  "state": {
    "flags": "69699",
    "address": "10.0.3.38",
    "maskAddress": "255.255.255.0",
    "broadcastAddress": "10.0.3.255",
    "macAddress": "74:da:38:41:b7:ac",
    "status": "connected"
  },
  "settings": {
    "type": "dhcp",
    "dns-nameservers": "10.0.1.12 208.201.224.11 208.201.224.33",
    "wpa-psk": "\"polymerase\"",
    "wpa-ssid": "\"Chai Guest\""
  }
}, currentSelectedNetwork = null;

app.get('/status', function (req, res, next) {
  res.send(data);
});
app.get('/device', function(req, res, next) {
  res.send(device);
});

app.post('/device/check_for_updates', function (req, res, next) {
  res.send(data);
});

app.get('/network/eth0', function (req, res, next) {
  res.send(ethernet); // here change to ethernet
});

app.get('/network/wlan/scan', function(req, res, next) {
  res.send(wifi_networks);
});
app.post('/network/wlan/connect', function(req, res, next) {
  res.send({
    "state": true
  });
});

app.post('/network/wlan/disconnect', function(req, res, next) {
  res.send(true);
});

app.get('/network/wlan', function(req, res, next) {

  if(currentSelectedNetwork === null) {
    res.send(defaultSelected);
  } else {
    res.send(currentSelectedNetwork);
  }
  /*res.status(405).send({
              "status":
              {
                  "status": "false",
                  "error": "No WIFI interface is present"
              }
            }
          );*/
});

app.put('/network/wlan', function(req, res, next) {
  currentSelectedNetwork = {
    "interface": "wlan1",
    "settings":
    {
      "type": "dhcp",
      "wpa-psk": "hgfh",
      "wpa-ssid": "Chai Test Net"
    },
    "state":
    {
      "flags": "69699",
      "address": "10.0.3.38",
      "maskAddress": "255.255.255.0",
      "broadcastAddress": "10.0.3.255",
      "macAddress": "74:da:38:41:b7:ac",
      "status": "connected"
    }
  };

  res.send({
    "state": true
  });
});

app.put('/network/eth0', function(req, res, next) {
  res.send({
    "state": true
  });
});

app.post('/control/start', function (req, res, next) {
  data = status_lid_heating;
  data.experiment_controller.experiment.id = req.body.experiment_id;
  startExperiment(req.body.experiment_id);
  experiment_id = req.body.experiment_id;
  setTimeout(function () {
    data.experiment_controller.machine.state = 'running';
    data.experiment_controller.machine.thermal_state = 'holding';
    autoupdateLogs();

  }, 3000);

  setTimeout(stop, 1000 * 60 * 60); //60 mins

  res.send(true);
});

function stop () {
  completeExperiment(experiment_id, function () {
    lastLog = null;
    clearTimeout(intrvl);
    setTimeout(function () {
      data = status_idle;
    }, 5000)
  });
}

app.post('/control/stop', function (req, res, next) {
  stop();
  res.send(true);
});

app.post('/device/upload_software_update', upload,function (req, res, next) {
  res.status(422).json({
    status: {
      status: false,
      error: 'Hello world'
    }
  });
});

app.post('/network/wlan/connect', function(req, res, next) {
  res.send({
    "state": true
  });
});

app.post('/network/wlan/disconnect', function(req, res, next) {
  res.send(true);
});


app.options('*',function (req, res, next) {
  res.send('CORS OPTIONS HERE');
});

app.listen(8000);
