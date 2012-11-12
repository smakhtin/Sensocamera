@App = {}
class @App.MainLoop
	constructor: () ->
		element = document.getElementById "accelerometerX"

		navigator.accelerometer.watchAcceleration(
			(acceleration) ->
				element.innerHTML = "<p>#{acceleration.x}</p>"
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:3000})

		testPlugin = new window.App.TestPlugin()
		testPlugin.callNativeFunction(
			() -> console.log "Working Good",
			() -> "Not Working", 
			"Bla")