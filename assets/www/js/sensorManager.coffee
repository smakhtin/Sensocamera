class @Sensocamera.SensorManager
	constructor: () ->
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