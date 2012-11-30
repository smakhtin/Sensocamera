@Sensocamera.CosmObjects = {}

@Sensocamera.Sensors = 
  ACCELEROMETER_X: "accelerometerX"
  ACCELEROMETER_Y: "accelerometerY"
  ACCELEROMETER_Z: "accelerometerZ"

  GAS: "gas"
  TEMPERATURE: "temperature"
  PRESSURE: "pressure"
  HUMIDITY: "humidity"
  LIGHT: "light"
  SOUND: "sound"
  
  COMPASS: "compass"

  LOCATION_LAT: "locationLat"
  LOCATION_LONG: "locationLong"
  LOCATION_ALT: "locationAlt"


@Sensocamera.CosmObjects.Feed = 
  title: "Sensocamera Stream"
  website: "http://mathrioshka.ru/sensocamera"
  version: "1.0.0"
  location:{
    disposition: "mobile"
  }
  datastreams:[
    {
      id: window.Sensocamera.Sensors.ACCELEROMETER_X
    },
    {
      id: window.Sensocamera.Sensors.ACCELEROMETER_Y
    },
    {
      id: window.Sensocamera.Sensors.ACCELEROMETER_Z
    },
    {
      id: window.Sensocamera.Sensors.GAS
    },
    {
      id: window.Sensocamera.Sensors.TEMPERATURE
    },
    {
      id: window.Sensocamera.Sensors.PRESSURE
    },
    {
      id: window.Sensocamera.Sensors.HUMIDITY
    },
    {
      id: window.Sensocamera.Sensors.LIGHT
    },
    {
      id: window.Sensocamera.Sensors.SOUND
    },
    {
      id: window.Sensocamera.Sensors.COMPASS
    },
    {
      id: window.Sensocamera.Sensors.LOCATION_LAT
    },
    {
      id: window.Sensocamera.Sensors.LOCATION_LONG
    },
    {
      id: window.Sensocamera.Sensors.LOCATION_ALT
    }
  ]