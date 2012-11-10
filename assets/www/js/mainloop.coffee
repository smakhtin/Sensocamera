window.App = {}
class window.App.MainLoop
	constructor: (@name) ->
		console.log("Main Loop Started")
		navigator.accelerometer.watchAcceleration(
			(acceleration) ->
				console.log acceleration.x
			, (error) ->
				console.log "Error: Can't access accelerometer"
			, {frequency:3000})