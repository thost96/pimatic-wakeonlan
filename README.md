# pimatic-wakeonlan

[![npm version](https://badge.fury.io/js/pimatic-wakeonlan.svg)](http://badge.fury.io/js/pimatic-wakeonlan)
[![dependencies status](https://david-dm.org/thost96/pimatic-wakeonlan/status.svg)](https://david-dm.org/thost96/pimatic-wakeonlan)

Plugin to Wake up you network devices using Pimatic

## Screenshots

![Screenshot 1](https://raw.githubusercontent.com/thost96/pimatic-wakeonlan/master/assets/screenshot.png)

## Plugin Configuration

Optionally, you can also set the `broadcastAddress` property to define the broadcast address, which is `255.255.255.255` by default. 
This may be required if you have an IPv6 network or you are running pimatic on Windows as Windows only routes packets with the global broadcast address to the first network interface. For the latter case a network-specific broadcast address may be specified to route packets to the appropriate network interface.

	{ 
   		"plugin": "wakeonlan"
	}


## Device Configuration

Devices for Wakeup can be defined by adding them to the `devices` section in the config file or using the device tab on the mobile frontend. Set the `class` attribute to `WakeOnLanDevice`. For example:

	{
  		"class": "WakeOnLanDevice",
  		"id": "pc-dad",
  		"name": "PC-Dad",
		"mac": "11:22:33:44:55:66"
	}

If you don't know the device mac address you also can use the device ip address. For example:

	{
  		"class": "WakeOnLanDevice",
  		"id": "pc-dad",
  		"name": "PC-Dad",
  		"host": "192.168.178.10"
	}

| Property          | Default  | Type    | Description                                 |
|:------------------|:---------|:--------|:--------------------------------------------|
| mac              	| -        | String  | MAC address of destination host|
| host 				| - 	   | String  | IP address or hostname of destination host|


## Rule support
You also can use the plugin within rules using `wol` or `wakeup` as command:

`WHEN {...} THEN wol "11:22:33:44:55:66"` or
`WHEN {...} THEN wakeup "11:22:33:44:55:66"` 

# History

See [Release History](https://github.com/thost96/pimatic-wakeonlan/blob/master/HISTORY.md).

# License 

Copyright (c) 2016, Thorsten Reichelt. All rights reserved.

License: [GPL-2.0](https://github.com/thost96/pimatic-wakeonlan/blob/master/LICENSE).

Icon made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> is licensed <a href="https://www.iconfinder.com/icons/99841/lan_icon" title="free for non commercial use">free for non commercial use</a>.