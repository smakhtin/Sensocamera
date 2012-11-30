class @Sensocamera.Controller
	db = window.openDatabase("sensocameraDB", "1.0", "Sensocamera DB", 1000000);

	recording = false
	feedValid = false
	feedID = "null"

	#UI Elements
	recordButton = null
	syncButton = null
	feedInput = null
	createFeedButton = null

	allSensors = [];
	sensorManager = null;

	checkPreferencesTable = () ->
		db.transaction(
			(tx) ->
				tx.executeSql "SELECT * FROM SETTINGS"
			, (error) ->
				console.log error
				db.transaction (tx) -> 
					tx.executeSql "CREATE TABLE SETTINGS(id integer primary key, name text, value text)"
					tx.executeSql "INSERT INTO SETTINGS(name, value) VALUES('feedID', '')"
			, (success) ->
				console.log "We already have PREFERENCES table, congratulations"
				checkPreferecnes()
		)

	checkPreferecnes = () ->
		result = null;

		db.transaction (tx) -> tx.executeSql("SELECT value FROM SETTINGS WHERE name='feedID'", [], 
			(tx, sqlResult) ->
				feedID = sqlResult.rows.item(0).value
				feedInput.val(feedID);
		)

	prepareObjects = () ->
		recordButton = $("#recordButton");
		recordButton.click record
		recordButton.addClass "startRecord"

		syncButton = $("#syncButton");
		syncButton.click sync
		
		feedInput = $("#feedID");
		feedInput.blur () ->
			id = feedInput[0].value

			if id != feedID
				feedID = id;
				checkFeed feedID;
		
		createFeedButton = $("#createFeedButton");
		createFeedButton.click () ->
			createFeed feedID;

		createFeedButton.button('disable')
		createFeedButton.button('refresh')

	listAvailableSensors = () ->
		allDatastreams = window.Sensocamera.CosmObjects.Feed.datastreams

		datastream.id for datastream in allDatastreams

	constructor: () ->
		checkPreferencesTable()
		prepareObjects()

		allSensors = listAvailableSensors()

		sensorManager = new window.Sensocamera.SensorManager(db, allSensors)
		console.log "Controller Initialiased"

	setState = (targetState) ->
		state = window.Sensocamera.State;
		switch targetStatestate
			when state.RECORD
				console.log targetState + "State"
			when state.STATUS
				console.log targetState + "State"
			when state.SETTINGS
				console.log targetState + "State"

	record = () ->
		console.log "Record Pressed"
		if recording
			recordButton.removeClass "stopRecord"
			recordButton.addClass "startRecord"
			
			sensorManager.stopRecord()

			recording = false;
			console.log "Stop Recording"
		else
			recordButton.removeClass "startRecord"
			recordButton.addClass "stopRecord"

			sensorManager.startRecord()

			recording = true;
			console.log "Start Recording"

	sync = () ->
		console.log "Syncing With Server"
		
		status = (sensorManager.syncSensor feedID, sensor for sensor in allSensors)

		for s in status
			if s != true
				console.log "Resync!"
				sync()
				return

		sensorManager.clearData()
		

	checkFeed = (value) ->
		console.log "Checking feed " + value

		cosm.feed.get value, (data) ->
			console.log "Request Satus " + data.status
			if data.status == 404
				console.log "Trying to enable button"

				createFeedButton.button('enable')
				createFeedButton.button('refresh')
			else
				db.transaction (tx) -> tx.executeSql "UPDATE SETTINGS SET value='#{value}' WHERE name='feedID'"

	createFeed = (value) ->
		console.log "Creating feed " + value

		feed = $.extend({}, window.Sensocamera.CosmObjects.Feed)

		cosm.feed.new(feed, 
			(data) -> 
				console.log data
		)

@Sensocamera.State = 
	RECORD: "record"
	STATUS: "status"
	SETTINGS: "settings"