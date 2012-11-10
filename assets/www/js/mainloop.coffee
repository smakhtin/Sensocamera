window.App = {}
class window.App.MainLoop
    constructor: (@name) ->
    	console.log("Main Loop Started")
    	setTimeout(update, 1000 / 1)

    update = () ->
    	console.log "Entered Frame"
    	navigator.accelerometer.getCurrentAcceleration(
    		(acceleration) ->
    			console.log acceleration.x
    		, (error) ->
    			console.log "Error: Can't access accelerometer"
    	)
    	setTimeout(update, 1000 / 1)