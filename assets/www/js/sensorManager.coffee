class @Sensocamera.SensorManager
	sensors = []
	sensorEnum = null
	db = null;

	record = false;

	checkSensorTable = (sensorId) ->
		sensorId = sensorId.toUpperCase()

		db.transaction(
			(tx) ->
				tx.executeSql "SELECT * FROM #{sensorId}"
			, (error) ->
				console.log error
				db.transaction (tx) -> 
					tx.executeSql "CREATE TABLE #{sensorId}(id integer primary key, at text, value text)"
			, (success) ->
				console.log "We already have #{sensorId} table, congratulations"
		)

	recordValue = (sensorId, sensorValue) ->
		currentDate = new Date()
		timeStamp = currentDate.toISOString()
		
		sensorId = sensorId.toUpperCase()
		
		db.transaction(
			(tx) -> 
				executionString = "INSERT INTO #{sensorId}(at, value) VALUES('#{timeStamp}', '#{sensorValue}')"
				tx.executeSql executionString
			, (error) -> 
				console.log error
				console.log "Can't record #{sensorId}"
			, (success) -> 
				console.log "#{sensorId} data recorded"
		)

	setupAccelerometer = () ->
		elementX = $("#accelerometerX")[0]
		elementY = $("#accelerometerY")[0]
		elementZ = $("#accelerometerZ")[0]

		navigator.accelerometer.watchAcceleration(
			(acceleration) ->
				accelerationX = acceleration.x
				accelerationY = acceleration.y
				accelerationZ = acceleration.z

				if(record)
					recordValue sensorEnum.ACCELEROMETER_X, accelerationX
					recordValue sensorEnum.ACCELEROMETER_Y, accelerationY
					recordValue sensorEnum.ACCELEROMETER_Z, accelerationZ

				elementX.innerHTML = accelerationX
				elementY.innerHTML = accelerationY
				elementZ.innerHTML = accelerationZ
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:3000})

	setupArduino = () ->
		testPlugin = new window.Sensocamera.TestPlugin()
		testPlugin.callNativeFunction(
			() -> console.log "Working Good",
			() -> "Not Working", 
			"Bla")

	constructor: (base, @sensors) ->
		console.log "SensorManager Started"

		sensorEnum = window.Sensocamera.Sensors
		
		db = base;
		
		checkSensorTable sensorId for sensorId in sensors

		setupAccelerometer()

		console.log "SensorManager Initialiased"

	syncSensor: (feedId, sensorId) ->
		console.log "Syncing sensor #{sensorId}"
		db.transaction (tx) ->
				tx.executeSql(
					"SELECT at, value FROM #{sensorId.toUpperCase()}", []
					, (tx, sqlResult) -> 
						data = (sqlResult.rows.item(i) for i in [0..sqlResult.rows.length - 1])
						console.log JSON.stringify(data)
						cosm.datapoint.new feedId, sensorId, {"datapoints":data}, (res) -> 
							console.log res
							if res.status == 200
								console.log "Delete stuff here"

							
					, (error) -> 
						console.log error
						console.log "Looks like we have some problems with #{sensorId} data"
				)

	startRecord: () ->
		record = true

	stopRecord: ()->
		record = false