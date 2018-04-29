Background Beacon Demo
=================

Created by Randy Edmonds from AppHands.com

Using CoreBluetooth to scan for (non-iBeacon) bluetooth beacons while the app is in the background.

Configure a Raspberry Pi as a bluetooth beacon using the following commands:
sudo hcitool -i hci0 cmd 0x08 0x0008 1F 02 01 1A 03 03 71 1E 17 FF 06 06 E2 0A 39 F4 73 F5 4B C4 A1 2F 17 D1 AD 07 A9 61 01 00 02 00 00
sudo hcitool hci0 leadv 3

This app will scan for bluetooth devices that have a Service UUID of 0x1E71 (bytes 8 and 9 in the above hcitool command).

When a bluetooth device is discovered:
When in the background, the app will display a local notification.
When in the foreground, the app will display the UUID, Major, Minor and Power.


Public Domain. Use as you wish.