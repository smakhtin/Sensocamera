class @Sensocamera.TestPlugin
	constructor: () ->

	callNativeFunction: (success, fail, param) ->
		return cordova.exec success, fail, "TestPlugin", "nativeAction", [param]