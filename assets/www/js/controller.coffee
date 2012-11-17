class @Sensocamera.Controller
	recording = false;
	datastreamValid = false;
	datastreamID = "null";

	PAUSE_IMAGE = "img/button-disabled.png"
	START_IMAGE = "img/button-enabled.png"

	constructor: () ->
		recordButton = $("#recordButton")[0];
		recordButton.onClick = record

		syncButton = $("#syncButton")[0];
		syncButton.onClick = sync

		datastreamInput = $("#datastreamID")[0];
		
		datastreamInput.onBlur = () ->
			id = datastreamInput.value

			if id != datastreamID
				datastreamID = id;
				checkDatastream datastreamInput.value;

		createDatastreamButton = $("#createDatastreamButton")[0];
		createDatastreamButton.onClick = () ->
			createDatastream(datastreamID);

	setState = (targetState) ->
		state = window.Sensocamera.State;
		switch targetStatestate
			when state.RECORD
				console.log targetState + "State"
			when state.STATUS
				console.log targetState + "State"
			when state.SETTINGS
				console.log targetState + "State"

	record = () ->
		if recording 
			recordButton.setAttribute("src", START_IMAGE)
			recording = false;
		else
			recordButton.setAttribute("src", PAUSE_IMAGE)
			recording = true;

	sync = () ->
		console.log "Syncing With Server"

	checkDatastream = (streamName) ->
		console.log "Checking Datastream " + streamName

	createDatastream = (streamName) ->
		console.log "Creating Datastream" + streamName

@Sensocamera.State = 
	RECORD: "record"
	STATUS: "status"
	SETTINGS: "settings"