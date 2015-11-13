pimatic-wakeonlan
=======================

Plugin to Wake up you network devices using Pimatic

Screenshots
-----------
[![Screenshot 1][screen1_thumb]](https://github.com/thost96/pimatic-wakeonlan/blob/master/screenshot.png)
[screen1_thumb]: https://github.com/thost96/pimatic-wakeonlan/blob/master/screenshot.png?v=1

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
If you don't know the device mac address you also can use the device ip address. For example:
```json
{
  "class": "WakeOnLanDevice",
  "id": "pc-dad",
  "name": "PC-Dad",
  "host": "192.168.178.10"
}
```

Rule support
------------
You also can use the plugin within rules using `wol` or `wakeup` as command:

```json
IF {something} THEN wol "11:22:33:44:55:66" or
IF {something} THEN wakeup "11:22:33:44:55:66" 
```


Credits
-------
Icon made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> is licensed <a href="https://www.iconfinder.com/icons/99841/lan_icon" title="free for non commercial use">free for non commercial use</a>.