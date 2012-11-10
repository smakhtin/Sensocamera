@app = {
	initialize: () ->
		this.bindEvents()

	bindEvents: ()->
		document.addEventListener 'deviceready', this.onDeviceReady, false

	onDeviceReady: () ->
        app.receivedEvent 'deviceready'
        console.log "Trying to start my application"
        mainloop = new window.App.MainLoop()

    receivedEvent: (id) ->
        parentElement = document.getElementById id
        listeningElement = parentElement.querySelector '.listening'
        receivedElement = parentElement.querySelector '.received'

        listeningElement.setAttribute 'style', 'display:none;'
        receivedElement.setAttribute 'style', 'display:block;'

        console.log 'Received Event: ' + id
}

