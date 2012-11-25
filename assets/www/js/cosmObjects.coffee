@Sensocamera.CosmObjects = {}

@Sensocamera.Sensors = 
  ACCELEROMETER_X: "accelerometerX"
  ACCELEROMETER_Y: "accelerometerY"
  ACCELEROMETER_Z: "accelerometerZ"

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
    }
  ]