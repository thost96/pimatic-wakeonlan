module.exports = (env) ->

  #Version 0.2.0

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'  
  M = env.matcher

  #WakeOnLAN
  wakeup = Promise.promisify (require 'wake_on_lan').wake

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
      #For Debugging
      #env.logger.debug @config

      if (@config.host isnt "" and @config.mac is "FF:FF:FF:FF:FF:FF" or "")
        #Get MAC if not defined
        arp.getMACAsync(config.host).then((macc) ->
          env.logger.info "Got MAC for Host " + config.host + ": " + macc
          config.mac = macc        
        )
      super(config)  
      

    #WakeOnLan Main Function
    wakeUp: (mac) ->       
      #Run Wake with MAC Address
      return wakeup(mac).then(x: (mac) =>
        #Returning Info to Console and Gui
        env.logger.info "Device with mac " + mac + " has been woken up"
      )
    

    #Handle ButtonPressed Event
    buttonPressed: (buttonId) ->
      for b in @config.buttons
        if b.id is buttonId
          @_lastPressedButton = b.id
          @emit 'button', b.id
          #For Debugging
          #env.logger.debug b.id
          #Run WakeUp with configured Mac
          return @wakeUp(@config.mac)

      throw new Error("No button with the id #{buttonId} found")


  #WakeOnLAnActionProvider to provide wakeup / wol for rules
  class WakeOnLAnActionProvider extends env.actions.ActionProvider

    constructor: (@framework, @config) ->

    parseAction: (input, context) =>
      macTokens = null
      setCommand = (m, tokens) => macTokens = tokens

      m = M(input, context)
      .match(['wol ','wakeup '])
      .matchStringWithVars(setCommand)

      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new WakeOnLanActionHandler(@framework, macTokens)
        }
      else
        return null


  #WakeOnLanActionHanler to handle actions for provided rules
  class WakeOnLanActionHandler extends env.actions.ActionHandler

    constructor: (@framework, @macTokens) ->

    executeAction: (simulate, context) ->
      @framework.variableManager.evaluateStringExpression(@macTokens).then( (mac) =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          return __("would wakeup device \"#{mac}\"")
        else
          return wakeup(mac).then( ->
            return __("Device with mac \"#{mac}\" has been woken up")
          )
      )    

  module.exports.WakeOnLanActionHandler = WakeOnLanActionHandler    

  # Create a instance of my plugin
  plugin = new WakeOnLan
  # and return it to the framework.
  return plugin
