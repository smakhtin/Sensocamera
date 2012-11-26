// Generated by CoffeeScript 1.4.0
(function() {

  this.Sensocamera.Controller = (function() {
    var allSensors, checkFeed, checkPreferecnes, checkPreferencesTable, createFeed, createFeedButton, db, feedID, feedInput, feedValid, listAvailableSensors, prepareObjects, record, recordButton, recording, sensorManager, setState, sync, syncButton;

    db = window.openDatabase("sensocameraDB", "1.0", "Sensocamera DB", 1000000);

    recording = false;

    feedValid = false;

    feedID = "null";

    recordButton = null;

    syncButton = null;

    feedInput = null;

    createFeedButton = null;

    allSensors = [];

    sensorManager = null;

    checkPreferencesTable = function() {
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT * FROM SETTINGS");
      }, function(error) {
        console.log(error);
        return db.transaction(function(tx) {
          tx.executeSql("CREATE TABLE SETTINGS(id integer primary key, name text, value text)");
          return tx.executeSql("INSERT INTO SETTINGS(name, value) VALUES('feedID', '')");
        });
      }, function(success) {
        console.log("We already have PREFERENCES table, congratulations");
        return checkPreferecnes();
      });
    };

    checkPreferecnes = function() {
      var result;
      result = null;
      return db.transaction(function(tx) {
        return tx.executeSql("SELECT value FROM SETTINGS WHERE name='feedID'", [], function(tx, sqlResult) {
          feedID = sqlResult.rows.item(0).value;
          return feedInput.val(feedID);
        });
      });
    };

    prepareObjects = function() {
      recordButton = $("#recordButton");
      recordButton.click(record);
      recordButton.addClass("startRecord");
      syncButton = $("#syncButton");
      syncButton.click(sync);
      feedInput = $("#feedID");
      feedInput.blur(function() {
        var id;
        id = feedInput[0].value;
        if (id !== feedID) {
          feedID = id;
          return checkFeed(feedID);
        }
      });
      createFeedButton = $("#createFeedButton");
      createFeedButton.click(function() {
        return createFeed(feedID);
      });
      createFeedButton.button('disable');
      return createFeedButton.button('refresh');
    };

    listAvailableSensors = function() {
      var allDatastreams, datastream, _i, _len, _results;
      allDatastreams = window.Sensocamera.CosmObjects.Feed.datastreams;
      _results = [];
      for (_i = 0, _len = allDatastreams.length; _i < _len; _i++) {
        datastream = allDatastreams[_i];
        _results.push(datastream.id);
      }
      return _results;
    };

    function Controller() {
      checkPreferencesTable();
      prepareObjects();
      allSensors = listAvailableSensors();
      sensorManager = new window.Sensocamera.SensorManager(db, allSensors);
      console.log("Controller Initialiased");
    }

    setState = function(targetState) {
      var state;
      state = window.Sensocamera.State;
      switch (targetStatestate) {
        case state.RECORD:
          return console.log(targetState + "State");
        case state.STATUS:
          return console.log(targetState + "State");
        case state.SETTINGS:
          return console.log(targetState + "State");
      }
    };

    record = function() {
      console.log("Record Pressed");
      if (recording) {
        recordButton.removeClass("stopRecord");
        recordButton.addClass("startRecord");
        sensorManager.stopRecord();
        recording = false;
        return console.log("Stop Recording");
      } else {
        recordButton.removeClass("startRecord");
        recordButton.addClass("stopRecord");
        sensorManager.startRecord();
        recording = true;
        return console.log("Start Recording");
      }
    };

    sync = function() {
      var sensor, _i, _len, _results;
      console.log("Syncing With Server");
      _results = [];
      for (_i = 0, _len = allSensors.length; _i < _len; _i++) {
        sensor = allSensors[_i];
        _results.push(sensorManager.syncSensor(feedID, sensor));
      }
      return _results;
    };

    checkFeed = function(value) {
      console.log("Checking feed " + value);
      return cosm.feed.get(value, function(data) {
        console.log("Request Satus " + data.status);
        if (data.status === 404) {
          console.log("Trying to enable button");
          createFeedButton.button('enable');
          return createFeedButton.button('refresh');
        } else {
          return db.transaction(function(tx) {
            return tx.executeSql("UPDATE SETTINGS SET value='" + value + "' WHERE name='feedID'");
          });
        }
      });
    };

    createFeed = function(value) {
      var feed;
      console.log("Creating feed " + value);
      feed = $.extend({}, window.Sensocamera.CosmObjects.Feed);
      /*testObject =
      			title: "Sensocamera Alpha Test",
      			version: "1.0.0",
      			datastreams:[{"id":"0"},{"id":"1"}]
      */

      return cosm.feed["new"](feed, function(data) {
        return console.log(data);
      });
    };

    return Controller;

  })();

  this.Sensocamera.State = {
    RECORD: "record",
    STATUS: "status",
    SETTINGS: "settings"
  };

}).call(this);