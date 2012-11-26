// Generated by CoffeeScript 1.4.0
(function() {

  this.Sensocamera.SensorManager = (function() {
    var checkSensorTable, db, record, recordValue, sensorEnum, sensors, setupAccelerometer, setupArduino;

    sensors = [];

    sensorEnum = null;

    db = null;

    record = false;

    checkSensorTable = function(sensorId) {
      sensorId = sensorId.toUpperCase();
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT * FROM " + sensorId);
      }, function(error) {
        console.log(error);
        return db.transaction(function(tx) {
          return tx.executeSql("CREATE TABLE " + sensorId + "(id integer primary key, at text, value text)");
        });
      }, function(success) {
        return console.log("We already have " + sensorId + " table, congratulations");
      });
    };

    recordValue = function(sensorId, sensorValue) {
      var currentDate, timeStamp;
      currentDate = new Date();
      timeStamp = currentDate.toISOString();
      sensorId = sensorId.toUpperCase();
      return db.transaction(function(tx) {
        var executionString;
        executionString = "INSERT INTO " + sensorId + "(at, value) VALUES('" + timeStamp + "', '" + sensorValue + "')";
        return tx.executeSql(executionString);
      }, function(error) {
        console.log(error);
        return console.log("Can't record " + sensorId);
      }, function(success) {
        return console.log("" + sensorId + " data recorded");
      });
    };

    setupAccelerometer = function() {
      var elementX, elementY, elementZ;
      elementX = $("#accelerometerX")[0];
      elementY = $("#accelerometerY")[0];
      elementZ = $("#accelerometerZ")[0];
      return navigator.accelerometer.watchAcceleration(function(acceleration) {
        var accelerationX, accelerationY, accelerationZ;
        accelerationX = acceleration.x;
        accelerationY = acceleration.y;
        accelerationZ = acceleration.z;
        if (record) {
          recordValue(sensorEnum.ACCELEROMETER_X, accelerationX);
          recordValue(sensorEnum.ACCELEROMETER_Y, accelerationY);
          recordValue(sensorEnum.ACCELEROMETER_Z, accelerationZ);
        }
        elementX.innerHTML = accelerationX;
        elementY.innerHTML = accelerationY;
        return elementZ.innerHTML = accelerationZ;
      }, function(error) {
        return console.log("Error: Can't access accelerometer");
      }, {
        frequency: 3000
      });
    };

    setupArduino = function() {
      var testPlugin;
      testPlugin = new window.Sensocamera.TestPlugin();
      return testPlugin.callNativeFunction(function() {
        return console.log("Working Good");
      }, function() {
        return "Not Working";
      }, "Bla");
    };

    function SensorManager(base, sensors) {
      var sensorId, _i, _len;
      this.sensors = sensors;
      console.log("SensorManager Started");
      sensorEnum = window.Sensocamera.Sensors;
      db = base;
      for (_i = 0, _len = sensors.length; _i < _len; _i++) {
        sensorId = sensors[_i];
        checkSensorTable(sensorId);
      }
      setupAccelerometer();
      console.log("SensorManager Initialiased");
    }

    SensorManager.prototype.syncSensor = function(feedId, sensorId) {
      console.log("Syncing sensor " + sensorId);
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT at, value FROM " + (sensorId.toUpperCase()), [], function(tx, sqlResult) {
          var data, i;
          data = (function() {
            var _i, _ref, _results;
            _results = [];
            for (i = _i = 0, _ref = sqlResult.rows.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
              _results.push(sqlResult.rows.item(i));
            }
            return _results;
          })();
          console.log(JSON.stringify(data));
          return cosm.datapoint["new"](feedId, sensorId, {
            "datapoints": data
          }, function(res) {
            console.log(res);
            if (res.status === 200) {
              return console.log("Delete stuff here");
            }
          });
        }, function(error) {
          console.log(error);
          return console.log("Looks like we have some problems with " + sensorId + " data");
        });
      });
    };

    SensorManager.prototype.startRecord = function() {
      return record = true;
    };

    SensorManager.prototype.stopRecord = function() {
      return record = false;
    };

    return SensorManager;

  })();

}).call(this);