module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'  
  M = env.matcher

  #WakeOnLAN
  wakeupCommand = Promise.promisify (require 'wake_on_lan').wake

  #Node-Arp 
  arpCommand = Promise.promisify (require 'node-arp').getMAC


  #WakeOnLan Plugin Class
  class WakeOnLan extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      @wakeupOptions =
        address: @config.broadcastAddress || "255.255.255.255"

      #Device Config Schema
      deviceConfigDef = require("./device-config-schema")

      #Register WakeOnLanDevice
      @framework.deviceManager.registerDeviceClass("WakeOnLanDevice", {
        configDef: deviceConfigDef.WakeOnLanDevice,
        createCallback: (config) => new WakeOnLanDevice(config)
      })
      #Register Action Handler for Rules
      @framework.ruleManager.addActionProvider(new WakeOnLAnActionProvider(@framework, @config))

  # Create a instance of my plugin
  plugin = new WakeOnLan

  #WakeOnLanDevice Class
  class WakeOnLanDevice extends env.devices.ButtonsDevice

    #Available Actions:
    actions:
      buttonPressed:
        params:
          buttonId:
            type: "string"

    #Initialise ButtonsDevice and create button if not defined
    constructor: (@config) ->
      @id = @config.id
      @name = @config.name        
      @config.buttons = [{"id": @id+"-btn","text": "WakeUp"}]
      #For Debugging
      #env.logger.debug @config
      config = @config
      if (@config.host isnt "" and @config.mac is "FF:FF:FF:FF:FF:FF" or "")
        #Get MAC if not defined
        arpCommand(config.host).then((mac) ->
          env.logger.info "Got MAC for Host " + config.host + ": " + mac
          config.mac = mac       
        )
      super(config)


    #Destroy ButtonsDevice
    destroy: () ->
      super()

    #WakeOnLan Main Function
    wakeUp: (mac) ->       
      #Run Wake with MAC Address
      return wakeupCommand(mac, plugin.wakeupOptions).then( ->
        #Returning Info to Console and Gui
        env.logger.info "Device with mac " + mac + " has been woken up"
        return Promise.resolve()
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
      setMac = (m, tokens) => macTokens = tokens

      m = M(input, context)
      .match(['wol ','wakeup '])
      .matchStringWithVars(setMac)

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
          return wakeupCommand(mac, plugin.wakeupOptions).then( ->
            env.logger.info "Device with mac " + mac + " has been woken up"
            return __("Device with mac \"#{mac}\" has been woken up")
          )
      )    

  module.exports.WakeOnLanActionHandler = WakeOnLanActionHandler    

  # and return it to the framework.
  return plugin
