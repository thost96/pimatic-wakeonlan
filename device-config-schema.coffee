module.exports = {
	title: "pimatic-wakeonlan device config schemas"
	WakeOnLanDevice: 
	  	title: "WakeOnLanDevice config options"
	  	type: "object"
	  	extensions: ["xLink"]
	  	properties:
	  		mac:
	  			description: "MAC Address of the Host"
	  			type: "string"
	  			default: "FF:FF:FF:FF:FF:FF"
	  		buttons:
	  			description: "Button will been automatically created"
	  			type: "array"
	  			default: []
}