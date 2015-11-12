module.exports = (env) ->

  #Version 0.2.0

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'  
  M = env.matcher

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
      #Register Action Handler for Rules
      @framework.ruleManager.addActionProvider(new WakeOnLAnActionProvider(@framework, config))


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
  

  #WakeOnLAnActionProvider to provide wakeup / wol for rules
  class WakeOnLAnActionProvider extends env.actions.ActionProvider
  
    constructor: (@framework, @config) ->
      return

    parseAction: (input, context) =>
      console.log "input"
      console.log input
      #wol "00:26:2d:04:60:8e"

      console.log "context"
      console.log context
      
      strToTokens = (str) => ["\"#{str}\""]

      console.log "strToTokens"
      console.log strToTokens
      #[Function]

      macTokens = strToTokens ""
      
      console.log "macTokens"
      console.log macTokens
      #[ '""' ]

      setMac = (m, tokens) => macTokens = tokens
      console.log "setMac"
      console.log(setMac)  
      #[Function]

      m = M(input, context)
        .match(['wol ','wakeup ']).matchStringWithVars(setMac)

      if m.hadMatch()
        match = m.getFullMatch()
        console.log "match"
        console.log match
        #wol "00:26:2d:04:60:8e"

        assert Array.isArray(macTokens)

        console.log "match.length"
        console.log match.length
        #23

        console.log "input.substring"
        console.log input.substring(match.length)
        # (no output)

        return {
          token: match          
          nextInput: input.substring(match.length)
          actionHandler: new WakeOnLanActionHandler(
            @framework, macTokens
          )
        }      


  #WakeOnLanActionHanler to handle actions for provided rules
  class WakeOnLanActionHandler extends env.actions.ActionHandler 

    constructor: (@framework, @macTokens) ->

    executeAction: (simulate, context) ->
      console.log "simulate"
      console.log simulate
      #undefined
      console.log "context"
      console.log context
      #undefined
      console.log "@macTokens"
      console.log @macTokens
      #[ '"00:26:2d:04:60:8e"' ]

      Promise.all( [
        @framework.variableManager.evaluateStringExpression(@macTokens)
      ]).then( ([mac]) =>
        console.log "mac"     
        console.log mac
        #00:26:2d:04:60:8e

        console.log "mac.length"
        console.log mac.length
        #17

        if simulate
          # just return a promise fulfilled with a description about what we would do.
          #return __("would wakeup device \"%s\"", mac)
        else 
          wol.wake(mac, (macc) -> 
            env.logger.info "Device with mac " + macc + " was waked Up"
            console.log macc
            #null
          )
            
          
      )    

  module.exports.WakeOnLanActionHandler = WakeOnLanActionHandler    

  # Create a instance of my plugin
  plugin = new WakeOnLan
  # and return it to the framework.
  return plugin
