@Sensocamera = {}

require 'libs/jquery-1.8.2'
require 'libs/jquery.mobile-1.2.0'
require 'cordova-2.2.0.js'

require 'js/mainloop'
require 'js/testPlugin'
require 'js/controller'

@main =
	initialize: () ->
		document.addEventListener 'deviceready', this.onDeviceReady, false

	onDeviceReady: () ->
		console.log "Trying to start my application"
		mainloop = new window.Sensocamera.MainLoop()

main.initialize()