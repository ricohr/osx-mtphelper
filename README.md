MTP Access helper for OSX
=========================

How to use
----------

### Execution with pipe

When starting with no command argument, MtpHelper will wait for MTP command from stdin.
Repeat until stdin is closed.

```
$ MtpHelper
deviceList
{"status":"OK","devices":["00000000-0000-0000-3030-313032313134"]}
desc 00000000-0000-0000-3030-313032313134 ExposureBiasCompensation
{"status":"OK","current":0,"factory_default_value":0,"values":[2000,1700,1300,1000,700,300,0,-300,-700,-1000,-1300,-1700,-2000]}
get 00000000-0000-0000-3030-313032313134 ExposureBiasCompensation
{"status":"OK","current":0}
set 00000000-0000-0000-3030-313032313134 ExposureBiasCompensation -2000
{"status":"OK"}
```

### Execution with command argument

If you specify the MTP command as the command argument, MtpHelper will be executed only once.

```
$ MtpHelper deviceList
{"status":"OK","devices":["00000000-0000-0000-3030-313032313134"]}
```
```
$ MtpHelper set 00000000-0000-0000-3030-313032313134 ExposureBiasCompensation -2000
{"status":"OK"}
```


Supported commands
------------------

### deviceList

Get a list of connected MTP devices.

```
deviceList
{"status":"OK", "devices":[ Array of DeviceId ]}
```

### deviceInfo

Get device informations of the specified MTP device.
```
deviceInfo DEVICE-ID
{"status":"OK", Hash of device information }
```

### desc

Gets the description of the specified device property.
```
desc DEVICE-ID PROPERTY-NAME
{"status":"OK", Hash of description }
```

### get

Gets the value of the specified device property.
```
get DEVICE-ID PROPERTY-NAME
{"status":"OK","current": Value of property }
```

### set

Sets the value of the specified device property.
```
set DEVICE-ID PROPERTY-NAME VALUE
{"status":"OK"}
```

### sendConfig

** FOR RICOH R ONLY **

Writes the config file to the device.
```
sendConfig DEVICE-ID CONFIG-FILENAME
{"status":"OK"}
```

### getConfig

** FOR RICOH R ONLY **

Read the config file from the device and save it to a file.
```
getConfig DEVICE-ID CONFIG-FILENAME
{"status":"OK"}
```

### firmwareUpdate

** FOR RICOH R ONLY **

Write the firmware file to the device.
```
firmwareUpdate DEVICE-ID FIRMWARE-FILE
{"status":"OK"}
```


Events
------

When a device is plugged / unplugged, an event message is output to the stderr.
```
{"event":"DeviceAdded","deviceId": Plugged DeviceId }
{"event":"DeviceRemoved","deviceId": Unplugged DeviceId }
```


Sample execution from electron
------------------------------

Start ``MtpHelper/Debug/mtphelper`` as a helper.

１. Launch application.
```
$ cd electron-sample
$ npm install
$ ./node_modules/.bin/electron .
```
２. Insert a command in the text box and press ENTER.
```
deviceList
```
３. Results are displayed below the text box.
```
{"status":"OK","devices":["00000000-0000-0000-3030-313032313134"]}
```


MtpHelper.json
--------------

This is a config file that MtpHelper refers to.
Place it in the same location as MtpHelper or specify it with ``-conf:JSON_FILENAME``.

Please see here for the specific content. [MtpHelper.json](https://github.com/ricohr/ricoh-r-console/blob/master/lib/mtphelper/MtpHelper.json)

### friendlyNames

An array of device names to search with ``deviceList``.

### properties

Available deviceProperty list.
You can add deviceProperty by increasing entries, but depending on the type you need to deal with MtpHelper.


Contributing
------------

Bug reports and pull requests are welcome on GitHub at https://github.com/ricohr/osx-mtphelper .


License
-------

This software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
