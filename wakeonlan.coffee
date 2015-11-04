module.exports = (env) ->

  #Version 0.2.0

  #Bluebird promise library
  Promise = env.require 'bluebird'

  #WakeOnLAN 
  wol = require 'wake_on_lan'
  Promise.promisifyAll(wol)

  #Node-Arp 
  arp = require 'node-arp'
  Promise.promisifyAll(arp)


  #WakeOnLan Plugin Class
  class WakeOnLan extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      
      #Device Config Schema
      deviceConfigDef = require("./device-config-schema")

      #Register WakeOnLanDevice
      @framework.deviceManager.registerDeviceClass("WakeOnLanDevice", {
        configDef: deviceConfigDef.WakeOnLanDevice, 
        createCallback: (config) => new WakeOnLanDevice(config)
      })

  #WakeOnLanDevice Class
  class WakeOnLanDevice extends env.devices.ButtonsDevice

    #Avaible Actions:
    actions:
      buttonPressed:
        params:
          buttonId:
            type: "string"

    #Initiaise ButtonsDevice and create button if not defined
    constructor: (@config) ->
      @id = config.id
      @name = @config.name        
      mac = config.mac
      @config.buttons = [{"id": @id+"-btn","text": "WakeUp"}]
      #For Debuggin
      #env.logger.debug @config

      if (@config.host isnt "" and @config.mac is "FF:FF:FF:FF:FF:FF" or "")
        #Get MAC if not defined
        arp.getMACAsync(config.host).then((macc) ->
          env.logger.info "Got MAC for Host " + config.host + ": " + macc
          config.mac = macc        
        )
      super(config)  
      

    #WakeOnLan Main Funktion
    wakeUp: (mac) ->       
      #Run Wake with MAC Adress
      return wol.wakeAsync(mac).then(x: (mac) =>
        #Returning Info to Console and Gui
        env.logger.info "Device with mac " + mac + " was waked Up"        
      )
    

    #Handle ButtonPressed Event
    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          #For Debuggin
          #env.logger.debug b.id
          #Run WakeUp with configured Mac
          return @wakeUp(@config.mac)

      throw new Error("No button with the id #{buttonId} found")
      
  # Create a instance of my plugin
  plugin = new WakeOnLan
  # and return it to the framework.
  return plugin
