class @Sensocamera.Controller
	db = window.openDatabase("sensocameraDB", "1.0", "Sensocamera DB", 1000000);

	recording = false;
	feedValid = false;
	feedID = "null";

	PAUSE_IMAGE = "img/button-disabled.png"
	START_IMAGE = "img/button-enabled.png"

	checkStorage = () ->
		db.transaction(
			(tx) ->
				tx.executeSql "SELECT * FROM SETTINGS"
			, (error) ->
				console.log error
				db.transaction (tx) -> 
					tx.executeSql "CREATE TABLE SETTINGS(id integer primary key, name text, value text)"
					tx.executeSql "INSERT INTO SETTINGS(name, value) VALUES('feedID', '')"
			, (success) ->
				console.log "We already have table, congratulations"
				checkPreferecnes()
		)

	checkPreferecnes = () ->
		result = null;

		db.transaction(
			(tx) ->
				tx.executeSql(
					"SELECT name, value FROM SETTINGS", []
					, (tx, results) ->
						console.log results
					, (error) -> 
						console.log "Looks like we have no preferences"
				)
			, (error) ->
				console.log error
			, (success) ->
				console.log success
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

	constructor: () ->
		checkStorage()
		prepareObjects()

		sensorManager = new window.Sensocamera.SensorManager()
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
		recordButton = $("#recordButton");
		if recording
			recordButton.removeClass "stopRecord"
			recordButton.addClass "startRecord"
			
			recording = false;
			console.log "Stop Recording"
		else
			recordButton.removeClass "startRecord"
			recordButton.addClass "stopRecord"

			recording = true;
			console.log "Start Recording"

	sync = () ->
		console.log "Syncing With Server"

	checkFeed = (value) ->
		console.log "Checking feed " + value

		cosm.feed.get value, (data) ->
			console.log "Request Satus " + data.status
			if data.status == 404
				console.log "Trying to enable button"

				createFeedButton = $("#createFeedButton");
				createFeedButton.button('enable')
				createFeedButton.button('refresh')
			else
				db.transaction (tx) -> tx.executeSql "UPDATE SETTINGS SET value='#{value}' WHERE name='feedID'"

	createFeed = (value) ->
		console.log "Creating feed " + value

		testObject =
  			title: "Sensocamera Alpha Test",
  			version: "1.0.0",
  			datastreams:[{"id":"0"},{"id":"1"}]

		cosm.feed.new(testObject, 
			(data) -> 
				console.log data
		)

@Sensocamera.State = 
	RECORD: "record"
	STATUS: "status"
	SETTINGS: "settings"