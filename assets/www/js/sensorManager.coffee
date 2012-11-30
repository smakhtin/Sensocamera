class @Sensocamera.SensorManager
	sensors = []
	sensorEnum = null
	db = null

	record = false
	recordPeriod = 3000

	sensorList = window.CosmObjects.Sensors

	sensorValues = {}

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
		if not record then return
		
		currentDate = new Date()
		timeStamp = currentDate.toISOString()

		for sensorName, sensorValue of sensorValues
			db.transaction(
				(tx) -> 
					executionString = "INSERT INTO SENSORS(name, at, value) VALUES('#{sensorName}', '#{timeStamp}', '#{sensorValue}')"
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
				sensorValues.accelerometerX = acceleration.x
				sensorValues.accelerometerY = acceleration.y
				sensorValues.accelerometerZ = acceleration.z

				elementX.innerHTML = accelerationX
				elementY.innerHTML = accelerationY
				elementZ.innerHTML = accelerationZ
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:1000})

	setupArduino = () ->
		gasElement = $("#gas")[0]
		temperatureElement = $("#temperature")[0]
		pressureElement = $("#pressure")[0]
		humidityElement = $("#humidity")[0]
		lightElement = $("#light")[0]

		adk = new window.Sensocamera.ADKBridge()
		adk.watchAcceleration(
			(success)-> 
				console.log "Updating sensor Values"
				if success is null or success is undefined then return

				sensorValues.gas = success.gas
				sensorValues.temperature = success.temperature
				sensorValues.pressure = success.pressure
				sensorValues.humidity = success.humidity
				sensorValues.light = success.light
				sensorValues.sound = success.sound

				gasElement.innerHTML = success.gas
				temperatureElement.innerHTML = success.temperature
				pressureElement.innerHTML = success.pressure
				humidityElement.innerHTML = success.humidity
				lightElement.innerHTML = success.light
		, (error)-> 
			error
		, 1000)

	setupCompass = ()->
		compassElement = $("#compass")[0]
		navigator.compass.watchHeading(
			(compass) -> 
				compassElement.innerHTML = compass.magneticHeading
			,(error) -> 
				console.log error
			, [{frequency:1000}])

	setupLocation = ()->
		latElement = $("#locationLat")[0]
		longElement = $("#locationLong")[0]
		altElement = $("#locationAlt")[0]
		headElement = $("#locationHead")[0]
		navigator.geolocation.watchPosition(
			(position)->
				console.log "Position Updated"

				sensorValues.locationLat = position.coords.latitude
				sensorValues.locationLong = position.coords.longitude

				sensorValues.locationAlt = position.coords.altitude

				latElement.innerHTML = position.coords.latitude
				longElement.innerHTML = position.coords.longitude
				altElement.innerHTML = position.coords.altitude
				console.log position.coords.altitude
				headElement.innerHTML = position.coords.heading
				console.log position.coords.heading
			,(error)-> 
					console.log error
			, {enableHighAccuracy: true}
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

		setTimeout(record, recordPeriod)

		console.log "SensorManager Initialiased"

	syncSensor: (feedId, sensorId) ->
		console.log "Syncing sensor #{sensorId}"
		db.transaction (tx) ->
			tx.executeSql(
				"SELECT at, value FROM #{sensorId.toUpperCase()}" []
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