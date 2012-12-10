// Generated by CoffeeScript 1.4.0
(function() {

  this.Sensocamera.SensorManager = (function() {
    var checkSensorsTable, datapointsRecorded, datapointsRecordedField, db, maxSyncAttemptsCount, pushData, record, recordPeriod, recordValues, sensorEnum, sensorValues, sensors, sensorsSynced, setDatapointsRecorded, setupAccelerometer, setupArduino, setupCompass, setupLocation, setupRecordCounter, updatePeriod;

    sensors = [];

    sensorEnum = null;

    db = null;

    record = false;

    recordPeriod = 3000;

    updatePeriod = 1000;

    maxSyncAttemptsCount = 2;

    sensorValues = {};

    datapointsRecorded = 0;

    datapointsRecordedField = null;

    sensorsSynced = 0;

    checkSensorsTable = function(sensorId) {
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT * FROM SENSORS");
      }, function(error) {
        console.log(error);
        return db.transaction(function(tx) {
          return tx.executeSql("CREATE TABLE SENSORS(id integer primary key, name text, at text, value text)");
        });
      }, function(success) {
        return console.log("We already have SENSORS table, congratulations");
      });
    };

    recordValues = function() {
      var currentDate, finalResult, result, sensorName, sensorValue, timeStamp;
      setTimeout(recordValues, recordPeriod);
      if (!record || datapointsRecorded >= 500) {
        return;
      }
      currentDate = new Date();
      timeStamp = currentDate.toISOString();
      finalResult = "";
      for (sensorName in sensorValues) {
        sensorValue = sensorValues[sensorName];
        result = "SELECT '" + sensorName + "', '" + timeStamp + "', '" + sensorValue + "' UNION ALL ";
        finalResult += result;
      }
      finalResult = finalResult.slice(0, -11);
      db.transaction(function(tx) {
        var executionString;
        executionString = "INSERT INTO SENSORS(name, at, value) " + finalResult;
        console.log(executionString);
        return tx.executeSql(executionString);
      }, function(error) {
        console.log(error);
        return console.log("Can't record");
      }, function(success) {
        return console.log("Data recorded");
      });
      return setDatapointsRecorded(datapointsRecorded + 1);
    };

    setDatapointsRecorded = function(value) {
      datapointsRecorded = value;
      datapointsRecordedField.innerHTML = datapointsRecorded;
      return db.transaction(function(tx) {
        tx.executeSql("UPDATE SETTINGS SET value='" + datapointsRecorded + "' WHERE name='datapointsRecorded'");
        return tx.executeSql("UPDATE SETTINGS SET value='" + sensorsSynced + "' WHERE name='sensorsSynced'");
      });
    };

    setupAccelerometer = function() {
      var elementX, elementY, elementZ;
      elementX = $("#accelerometerX")[0];
      elementY = $("#accelerometerY")[0];
      elementZ = $("#accelerometerZ")[0];
      return navigator.accelerometer.watchAcceleration(function(acceleration) {
        sensorValues.accelerometerX = acceleration.x;
        sensorValues.accelerometerY = acceleration.y;
        sensorValues.accelerometerZ = acceleration.z;
        elementX.innerHTML = sensorValues.accelerometerX;
        elementY.innerHTML = sensorValues.accelerometerY;
        return elementZ.innerHTML = sensorValues.accelerometerZ;
      }, function(error) {
        return console.log("Error: Can't access accelerometer");
      }, {
        frequency: updatePeriod
      });
    };

    setupArduino = function() {
      var adk, gasElement, humidityElement, lightElement, pressureElement, soundElement, temperatureElement;
      gasElement = $("#gas")[0];
      temperatureElement = $("#temperature")[0];
      pressureElement = $("#pressure")[0];
      humidityElement = $("#humidity")[0];
      lightElement = $("#light")[0];
      soundElement = $("#sound")[0];
      adk = new window.Sensocamera.ADKBridge();
      return adk.watchAcceleration(function(success) {
        var sound;
        if (success === null || success === void 0) {
          return;
        }
        sound = success.sound;
        sensorValues.gas = success.gas;
        sensorValues.temperature = success.temperature;
        sensorValues.pressure = success.pressure;
        sensorValues.humidity = success.humidity;
        sensorValues.light = success.light;
        if (sound !== void 0 && sound !== null) {
          sensorValues.sound = success.sound;
        }
        gasElement.innerHTML = success.gas;
        temperatureElement.innerHTML = success.temperature;
        pressureElement.innerHTML = success.pressure;
        humidityElement.innerHTML = success.humidity;
        lightElement.innerHTML = success.light;
        return soundElement.innerHTML = success.sound;
      }, function(error) {
        return error;
      }, updatePeriod);
    };

    setupCompass = function() {
      var compassElement;
      compassElement = $("#compass")[0];
      return navigator.compass.watchHeading(function(compass) {
        var heading;
        heading = compass.magneticHeading;
        if (heading !== void 0 && heading !== null) {
          sensorValues.compass = heading;
        }
        return compassElement.innerHTML = compass.magneticHeading;
      }, function(error) {
        return console.log(error);
      }, [
        {
          frequency: updatePeriod
        }
      ]);
    };

    setupLocation = function() {
      var altElement, headElement, latElement, longElement;
      latElement = $("#locationLat")[0];
      longElement = $("#locationLong")[0];
      altElement = $("#locationAlt")[0];
      headElement = $("#locationHead")[0];
      return navigator.geolocation.watchPosition(function(position) {
        var alt, lat, long;
        lat = position.coords.latitude;
        long = position.coords.longitude;
        alt = position.coords.altitude;
        sensorValues.locationLat = lat;
        sensorValues.locationLong = long;
        if (alt !== void 0 && alt !== null) {
          sensorValues.locationAlt = alt;
        }
        latElement.innerHTML = lat;
        longElement.innerHTML = long;
        altElement.innerHTML = alt;
        return headElement.innerHTML = position.coords.heading;
      }, function(error) {
        return console.log(error);
      }, {
        enableHighAccuracy: true
      });
    };

    setupRecordCounter = function() {
      datapointsRecordedField = $("#recordedCount")[0];
      db.transaction(function(tx) {
        return tx.executeSql("SELECT value FROM SETTINGS WHERE name='sensorsSynced'", [], function(tx, sqlResult) {
          return sensorsSynced = parseInt(sqlResult.rows.item(0).value);
        });
      });
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT value FROM SETTINGS WHERE name='datapointsRecorded'", [], function(tx, sqlResult) {
          return setDatapointsRecorded(parseInt(sqlResult.rows.item(0).value));
        });
      });
    };

    function SensorManager(base, sensors) {
      var id, _i, _len;
      this.sensors = sensors;
      console.log("SensorManager Started");
      sensorEnum = window.Sensocamera.Sensors;
      db = base;
      checkSensorsTable();
      for (_i = 0, _len = sensors.length; _i < _len; _i++) {
        id = sensors[_i];
        sensorValues[id] = 0;
      }
      setupAccelerometer();
      setupArduino();
      setupCompass();
      setupLocation();
      setupRecordCounter();
      setTimeout(recordValues, recordPeriod);
      console.log("SensorManager Initialized");
    }

    SensorManager.prototype.syncSensor = function(feedId, sensorId) {
      console.log("Syncing sensor " + sensorId);
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT at, value FROM SENSORS WHERE name='" + sensorId + "'", [], function(tx, sqlResult) {
          var data, i;
          if (sqlResult.rows.length <= 0) {
            console.log("No Data Recorded for " + sensorId);
            return;
          }
          data = (function() {
            var _i, _ref, _results;
            _results = [];
            for (i = _i = 0, _ref = sqlResult.rows.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
              _results.push(sqlResult.rows.item(i));
            }
            return _results;
          })();
          return pushData(feedId, sensorId, data);
        }, function(error) {
          return console.log("Cannot perform SELECT query for " + sensorId);
        });
      });
    };

    pushData = function(feedId, sensorId, data) {
      console.log("Pushing data of " + sensorId);
      return cosm.datapoint["new"](feedId, sensorId, {
        "datapoints": data
      }, function(res) {
        if (res.status === 200) {
          console.log("Synced data for " + sensorId + ". Now clearing.");
          db.transaction(function(tx) {
            return tx.executeSql("DELETE FROM SENSORS WHERE name='" + sensorId + "'");
          });
          sensorsSynced++;
          if (sensorsSynced >= Object.keys(sensorValues).length) {
            setDatapointsRecorded(0);
            return sensorsSynced = 0;
          }
        } else {
          console.log("Can't push data for " + sensorId);
          return console.log(res);
        }
      });
    };

    SensorManager.prototype.clearAllData = function() {
      console.log("Clearing Data");
      return db.transaction(function(tx) {
        return tx.executeSql("DELETE FROM SENSORS");
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
