class @Sensocamera.SensorManager
	db = null
	sensors = []

	checkSensorTable = (sensorId) ->
		db.transaction(
			(tx) ->
				tx.executeSql "SELECT * FROM #{sensorId}"
			, (error) ->
				console.log error
				db.transaction (tx) -> 
					tx.executeSql "CREATE TABLE SETTINGS(id integer primary key, at text, value text)"
					# tx.executeSql "INSERT INTO SETTINGS(name, value) VALUES('feedID', '')"
			, (success) ->
				console.log "We already have #{sensorId} table, congratulations"
				checkPreferecnes()
		)

	recordValue = (sensorId, sensorValue) ->
		currentDate = new Date()
		timeStamp = currentDate.toISOString()
		sensorId = sensorId.toUpperCase()
		db.transaction (tx) -> tx.executeSql "INSERT INTO SETTINGS(at, value) VALUES(#{timeStamp}, #{sensorValue})"

	constructor: (@db, @sensors) ->
		checkSensorTable sensorId for sensorId in sensors

		element = $("#accelerometerX")[0]

		navigator.accelerometer.watchAcceleration(
			(acceleration) ->
				element.innerHTML = acceleration.x
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:3000})

		testPlugin = new window.Sensocamera.TestPlugin()
		testPlugin.callNativeFunction(
			() -> console.log "Working Good",
			() -> "Not Working", 
			"Bla")

		console.log "SensorManager Initialiased"