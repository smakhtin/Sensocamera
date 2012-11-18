@Sensocamera = {}

@Sensocamera.main =
	initialize: () ->
		document.addEventListener 'deviceready', this.onDeviceReady, false

	onDeviceReady: () ->
		console.log "Trying to start my application"
		controller = new window.Sensocamera.Controller()

		cosm.setKey "crdgU-4DpnrC86ScfEDYgWDDh3Mtf8bpk5ZyXfRDNuI"

		$.support.cors = true