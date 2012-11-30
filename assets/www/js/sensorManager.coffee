class @Sensocamera.SensorManager
	sensors = []
	sensorEnum = null
	db = null

	record = false
	recordPeriod = 3000

	updatePeriod = 1000

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
		setTimeout(recordValues, recordPeriod)
		if not record then return
		
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
		sensorValue

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

	setupArduino = () ->
		gasElement = $("#gas")[0]
		temperatureElement = $("#temperature")[0]
		pressureElement = $("#pressure")[0]
		humidityElement = $("#humidity")[0]
		lightElement = $("#light")[0]

		adk = new window.Sensocamera.ADKBridge()
		adk.watchAcceleration(
			(success)-> 
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
		, updatePeriod)

	setupCompass = ()->
		compassElement = $("#compass")[0]
		navigator.compass.watchHeading(
			(compass) -> 
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

		setTimeout(recordValues, recordPeriod)

		console.log "SensorManager Initialized"

	syncSensor: (feedId, sensorId) ->
		console.log "Syncing sensors"
		db.transaction (tx) ->
			tx.executeSql(
				"SELECT at, value FROM SENSORS WHERE name='#{sensorId}'", []
				, (tx, sqlResult) -> 
					if(sqlResult.rows.length <= 0) 
						return false
					data = (sqlResult.rows.item(i) for i in [0..sqlResult.rows.length - 1])
					console.log JSON.stringify(data)
					cosm.datapoint.new feedId, sensorId, {"datapoints":data}, (res) -> 
						console.log res
						if res.status == 200
							console.log "Delete stuff here"
						else
							return false

						
				, (error) -> 
					console.log error
					console.log "Looks like we have some problems with #{sensorId} data"
			)

		return true

	clearData: ()->
		console.log "Clearing Data"
		db.transaction (tx)-> tx.executeSql "DELETE FROM SENSORS"

	startRecord: () ->
		record = true

	stopRecord: ()->
		record = false