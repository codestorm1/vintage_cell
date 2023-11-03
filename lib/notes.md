* Wed Nov 1, 2023
> Starting this nerves_cell project.
> Added .envrc, VintageNet Wifi configuration and keypad dep.  
> Got keypad working with Physical keypad Adafruit 1824 https://www.adafruit.com/product/1824
> Using hex package "keypad" (https://github.com/jjcarstens/keypad) for input

* Thu Nov 2, 2023
> Added this notes.md file

* TODO:
* Pull ModemServer from VintageCell and make it shareable (shared module on gitub? open source it as fona_phone?  release on hex.pm?)
* main app is gen_statem server?
* how to dial?  all timing, as "keypad" package offers, or on hook off hook switch? or # and * for on/off hook

* How should it work?
* need a button for hanging up.  Physical button or use # on keypad?
* need a button to answer incoming calls.  Physical button or use * on keypad?
