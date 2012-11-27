class @Sensocamera.ADKBridge
	START_ACTION = "start"
	STOP_ACTION = "stop"

	STATE_STOPPED = 0
	STATE_STARTING = 1
	STATE_RUNNING =  2
	STATE_FAILED = 3

	currentState = STATE_STOPPED

	refreshPeriod = 0
	timeoutAction = null

	sensors = null;

	constructor: ()->
		setState(STATE_STARTING)

	watchAcceleration: (success, error, period)->
		setState(STATE_STARTING)
		refreshPeriod = period
		timeoutAction = setTimeout (() -> success(sensors)), refreshPeriod

	callNativeFunction = (action, params) ->
		cordova.exec(
			(success)->
				if currentState is STATE_STARTING
					setState(STATE_RUNNING)
					console.log success
					sensors = success
			,(error)->
				if currentState is STATE_STARTING
					setState STATE_FAILED
					console.log error
			, "ADKBridge", action, params
		)

	setState = (state) ->
		if currentState is state then return

		currentState = state;

		switch currentState
			when STATE_STOPPED
				callNativeFunction(STOP_ACTION, [])
				clearTimeout(timeoutAction)
			when STATE_STARTING
				console.log "Starting ADK"
				callNativeFunction(START_ACTION, [])
			when STATE_FAILED
				console.log "ADKBridge failded to start"