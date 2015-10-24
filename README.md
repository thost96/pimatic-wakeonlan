pimatic-wakeonlan
=======================

Plugin to Wake up you network devices

Configuration
-------------
You can load the plugin by editing your `config.json`:

````json
{ 
   "plugin": "wakeonlan"
}
````

Device to wakeup can be defined by adding them to the `devices` section in the config file. Set the `class`attribute to `WakeOnLanDevice`. For example:
```json
{
  "class": "WakeOnLanDevice",
  "id": "pc-dad",
  "name": "PC-Dad",
  "mac": "11:22:33:44:55:66"
}
```

Originally inspired by ("node_wake_on_lan":https://github.com/agnat/node_wake_on_lan) from ("agnat":https://github.com/agnat/). 


