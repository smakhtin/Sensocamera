// Generated by CoffeeScript 1.4.0
(function() {

  this.Sensocamera.SensorManager = (function() {
    var checkSensorTable, db, recordValue, sensors;

    db = null;

    sensors = [];

    checkSensorTable = function(sensorId) {
      sensorId = sensorId.toUpperCase();
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT * FROM " + sensorId);
      }, function(error) {
        console.log(error);
        return db.transaction(function(tx) {
          return tx.executeSql("CREATE TABLE SETTINGS(id integer primary key, at text, value text)");
        });
      }, function(success) {
        console.log("We already have " + sensorId + " table, congratulations");
        return checkPreferecnes();
      });
    };

    recordValue = function(sensorId, sensorValue) {
      var currentDate, timeStamp;
      currentDate = new Date();
      timeStamp = currentDate.toISOString();
      sensorId = sensorId.toUpperCase();
      return db.transaction(function(tx) {
        return tx.executeSql("INSERT INTO SETTINGS(at, value) VALUES(" + timeStamp + ", " + sensorValue + ")");
      });
    };

    function SensorManager(db, sensors) {
      var element, sensorId, testPlugin, _i, _len;
      this.db = db;
      this.sensors = sensors;
      for (_i = 0, _len = sensors.length; _i < _len; _i++) {
        sensorId = sensors[_i];
        checkSensorTable(sensorId);
      }
      element = $("#accelerometerX")[0];
      navigator.accelerometer.watchAcceleration(function(acceleration) {
        return element.innerHTML = acceleration.x;
      }, function(error) {
        return console.log("Error: Can't access accelerometer");
      }, {
        frequency: 3000
      });
      testPlugin = new window.Sensocamera.TestPlugin();
      testPlugin.callNativeFunction(function() {
        return console.log("Working Good");
      }, function() {
        return "Not Working";
      }, "Bla");
      console.log("SensorManager Initialiased");
    }

    return SensorManager;

  })();

}).call(this);
