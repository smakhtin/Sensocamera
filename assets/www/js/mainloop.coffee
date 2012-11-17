class @Sensocamera.MainLoop
	constructor: () ->
		element = $("#accelerometerX")[0]

		navigator.accelerometer.watchAcceleration(
			(acceleration) ->
				element.innerHTML = acceleration.x
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:3000})

		testPlugin = new window.App.TestPlugin()
		testPlugin.callNativeFunction(
			() -> console.log "Working Good",
			() -> "Not Working", 
			"Bla")