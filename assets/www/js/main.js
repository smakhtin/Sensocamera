// Generated by CoffeeScript 1.4.0
(function() {

  this.Sensocamera = {};

  this.Sensocamera.main = {
    initialize: function() {
      return document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    onDeviceReady: function() {
      var controller;
      console.log("Trying to start my application");
      controller = new window.Sensocamera.Controller();
      cosm.setKey("crdgU-4DpnrC86ScfEDYgWDDh3Mtf8bpk5ZyXfRDNuI");
      return $.support.cors = true;
    }
  };

}).call(this);
