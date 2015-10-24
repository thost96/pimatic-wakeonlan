pimatic-wakeonlan
=======================

Plugin to Wake up you network devices using Pimatic

Screenshots
-----------
[![Screenshot 1][screen1_thumb]](screenshot.png)
[screen1_thumb]: screenshot.png?v=1

Configuration
-------------
You can load the plugin by editing your `config.json` and adding the following in the `plugins` section:

````json
{ 
   "plugin": "wakeonlan"
}
````

Devices for Wakeup can be defined by adding them to the `devices` section in the config file. Set the `class` attribute to `WakeOnLanDevice`. For example:
```json
{
  "class": "WakeOnLanDevice",
  "id": "pc-dad",
  "name": "PC-Dad",
  "mac": "11:22:33:44:55:66"
}
```

Originally inspired by [node_wake_on_lan](https://github.com/agnat/node_wake_on_lan). 


