@app = {
	initialize: () ->
		this.bindEvents()

	bindEvents: ()->
		document.addEventListener 'deviceready', this.onDeviceReady, false

	onDeviceReady: () ->
		console.log "Trying to start my application"
		mainloop = new window.App.MainLoop()
}