class @Sensocamera.SensorManager
	sensors = []
	sensorEnum = null
	db = null

	record = false
	recordPeriod = 3000

	updatePeriod = 1000

	maxSyncAttemptsCount = 2

	sensorValues = {}

	datapointsRecorded = 0
	datapointsRecordedField = null
	sensorsSynced = 0

	checkSensorsTable = (sensorId) ->
		db.transaction(
			(tx) ->
				tx.executeSql "SELECT * FROM SENSORS"
			, (error) ->
				console.log error
				db.transaction (tx) -> 
					tx.executeSql "CREATE TABLE SENSORS(id integer primary key, name text, at text, value text)"
			, (success) ->
				console.log "We already have SENSORS table, congratulations"
		)

	recordValues = () ->
		setTimeout(recordValues, recordPeriod)
		
		if not record or datapointsRecorded >= 500 then return
		
		currentDate = new Date()
		timeStamp = currentDate.toISOString()

		finalResult = ""
		for sensorName, sensorValue of sensorValues
			result = "SELECT '#{sensorName}', '#{timeStamp}', '#{sensorValue}' UNION ALL "
			finalResult += result

		finalResult = finalResult.slice(0, -11)
		db.transaction(
			(tx) -> 
				executionString = "INSERT INTO SENSORS(name, at, value) #{finalResult}"
				console.log executionString
				tx.executeSql executionString
			, (error) -> 
				console.log error
				console.log "Can't record"
			, (success) -> 
				console.log "Data recorded"
		)

		setDatapointsRecorded datapointsRecorded + 1
		

	setDatapointsRecorded = (value)->
		datapointsRecorded = value
		datapointsRecordedField.innerHTML = datapointsRecorded
		db.transaction (tx) -> 
			tx.executeSql "UPDATE SETTINGS SET value='#{datapointsRecorded}' WHERE name='datapointsRecorded'"
			tx.executeSql "UPDATE SETTINGS SET value='#{sensorsSynced}' WHERE name='sensorsSynced'"

	setupAccelerometer = () ->
		elementX = $("#accelerometerX")[0]
		elementY = $("#accelerometerY")[0]
		elementZ = $("#accelerometerZ")[0]

		navigator.accelerometer.watchAcceleration(
			(acceleration) ->
				sensorValues.accelerometerX = acceleration.x
				sensorValues.accelerometerY = acceleration.y
				sensorValues.accelerometerZ = acceleration.z

				elementX.innerHTML = sensorValues.accelerometerX
				elementY.innerHTML = sensorValues.accelerometerY
				elementZ.innerHTML = sensorValues.accelerometerZ
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:updatePeriod})

	setupManeticField = () ->
		magneticFieldXElement = $("#magneticFieldX")[0];
		magneticFieldYElement = $("#magneticFieldY")[0];
		magneticFieldZElement = $("#magneticFieldZ")[0];

		magneticField = new window.Sensocamera.ExternalSensor "MagneticField"
		magneticField.watchData(
			(success)-> 
				if success is null or success is undefined then return

				magneticFieldXElement.innerHTML = sensorValues.magneticFieldX = success.x;
				magneticFieldYElement.innerHTML = sensorValues.magneticFieldY = success.y;
				magneticFieldZElement.innerHTML = sensorValues.magneticFieldZ = success.z;
		, (error)->
			error
		, updatePeriod)

	setupArduino = () ->
		gasElement = $("#gas")[0]
		temperatureElement = $("#temperature")[0]
		pressureElement = $("#pressure")[0]
		humidityElement = $("#humidity")[0]
		lightElement = $("#light")[0]
		soundElement = $("#sound")[0]

		colorRElement = $('#colorR')[0];
		colorGElement = $('#colorG')[0];
		colorBElement = $('#colorB')[0];

		adk = new window.Sensocamera.ExternalSensor "ADKBridge"
		adk.watchData(
			(success)-> 
				if success is null or success is undefined then return

				sound = success.sound

				sensorValues.gas = success.gas
				sensorValues.temperature = success.temperature
				sensorValues.pressure = success.pressure
				sensorValues.humidity = success.humidity
				sensorValues.light = success.light
				sensorValues.sound = success.sound if sound != undefined and sound != null
				
				sensorValues.colorR = success.colorR;
				sensorValues.colorG = success.colorG;
				sensorValues.colorB = success.colorB;

				gasElement.innerHTML = success.gas
				temperatureElement.innerHTML = success.temperature
				pressureElement.innerHTML = success.pressure
				humidityElement.innerHTML = success.humidity
				lightElement.innerHTML = success.light
				soundElement.innerHTML = success.sound

				colorRElement.innerHTML = success.colorR
				colorGElement.innerHTML = success.colorG
				colorBElement.innerHTML = success.colorB
		, (error)-> 
			error
		, updatePeriod)

	setupCompass = ()->
		compassElement = $("#compass")[0]
		navigator.compass.watchHeading(
			(compass) -> 
				heading = compass.magneticHeading
				sensorValues.compass = heading if heading != undefined and heading != null
				compassElement.innerHTML = compass.magneticHeading
			,(error) -> 
				console.log error
			, [{frequency:updatePeriod}])

	setupLocation = ()->
		latElement = $("#locationLat")[0]
		longElement = $("#locationLong")[0]
		altElement = $("#locationAlt")[0]
		headElement = $("#locationHead")[0]
		navigator.geolocation.watchPosition(
			(position)->
				lat = position.coords.latitude
				long = position.coords.longitude
				alt = position.coords.altitude

				sensorValues.locationLat = lat
				sensorValues.locationLong = long
				sensorValues.locationAlt = alt if alt != undefined and alt != null

				latElement.innerHTML = lat
				longElement.innerHTML = long
				altElement.innerHTML = alt
				headElement.innerHTML = position.coords.heading
			,(error)-> 
					console.log error
			, {enableHighAccuracy: true}
		)

	setupRecordCounter = ()->
		datapointsRecordedField = $("#recordedCount")[0]
		db.transaction (tx) -> tx.executeSql("SELECT value FROM SETTINGS WHERE name='sensorsSynced'", [],
			(tx, sqlResult) ->
				sensorsSynced = parseInt(sqlResult.rows.item(0).value)
		)

		db.transaction (tx) -> tx.executeSql("SELECT value FROM SETTINGS WHERE name='datapointsRecorded'", [],
			(tx, sqlResult) ->
				setDatapointsRecorded parseInt(sqlResult.rows.item(0).value)
		)

	constructor: (base, @sensors) ->
		console.log "SensorManager Started"

		sensorEnum = window.Sensocamera.Sensors
		
		db = base;
		
		checkSensorsTable()

		sensorValues[id] = 0 for id in sensors

		setupAccelerometer()
		setupArduino()
		setupCompass()
		setupLocation()
		
		setupRecordCounter()

		setTimeout(recordValues, recordPeriod)

		console.log "SensorManager Initialized"

	syncSensor: (feedId, sensorId) ->
		console.log "Syncing sensor #{sensorId}"

		db.transaction (tx) ->
			tx.executeSql(
				"SELECT at, value FROM SENSORS WHERE name='#{sensorId}'", []
				, (tx, sqlResult) -> 
					if sqlResult.rows.length <= 0
						console.log "No Data Recorded for #{sensorId}"
						return

					data = (sqlResult.rows.item(i) for i in [0..sqlResult.rows.length - 1])
					
					pushData(feedId, sensorId, data)
				, (error) ->
					console.log "Cannot perform SELECT query for #{sensorId}"
			)

	pushData = (feedId, sensorId, data) ->
		console.log "Pushing data of #{sensorId}"
		cosm.datapoint.new feedId, sensorId, {"datapoints":data}
		, (res) ->
			if res.status == 200
				console.log "Synced data for #{sensorId}. Now clearing."
				db.transaction (tx)-> tx.executeSql "DELETE FROM SENSORS WHERE name='#{sensorId}'"
				sensorsSynced++

				if(sensorsSynced >= Object.keys(sensorValues).length)
					setDatapointsRecorded 0
					sensorsSynced = 0
			else
				console.log "Can't push data for #{sensorId}"
				console.log res				

	clearAllData: ()->
		console.log "Clearing Data"
		db.transaction (tx)-> tx.executeSql "DELETE FROM SENSORS"

	startRecord: () ->
		record = true

	stopRecord: ()->
		record = false