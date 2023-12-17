* Wed Nov 1, 2023
> Starting this nerves_cell project.
> Added .envrc, VintageNet Wifi configuration and keypad dep.  
> Got keypad working with Physical keypad Adafruit 1824 https://www.adafruit.com/product/1824
> Using hex package "keypad" (https://github.com/jjcarstens/keypad) for input

* Thu Nov 2, 2023
> Added this notes.md file

* Fri Nov 3, 2023
> how to dial?  all timing, as "keypad" package offers, or on hook off hook switch? or # and * for on/off hook <- going with * and #
> Added a finite state machine diagram in Visual Paradigm for the flow of phone calls


* Sat Nov 4, 2023
> set up fona_modem repo to be used as a library by this app
> used a local path to do this.  This seems easier than bumping tags to get latest fona_modem
> It has a repo, codestorm1/fona_modem.

* Sat Nov 18, 2023
> Added a wire to the FONA-Pi board that I'm using for nerves cell - Grounded the FONA to the Pi.
> Able to reference FonaModem now as a local dependency
> Able to get the FONA to respond to AT commands
> Last time it booted, it was able to sync with AT modem commands and responses, although one response was ERROR 
> got FONA to make a call using IEx {:status, pid, _, _} = :sys.get_status(FonaModem)

* Sun Nov 19, 2023
> Nothing?!

* Sun Nov 26, 2023
> ???

* Wed Nov 29
> Fixed problem where Keypad GenServer wouldn't start.  Looks like Keypad package implemented a start_link with no params instead of start_link/1.  If that's correct, make an issue/PR?
> Was able to see keypresses of all keys in the Logger

Thu Nov 30
> Forked Keypad, changed start_link to have 1 param instead of 0 in keypad.ex.  Changed ref to use local forked version.
> Not sure if this is an issue with keypad package or if I just needed to implement my own start_link/1
> got keypad detecting keypresses and sending AT commands to the FONA 3G also works. 

Fri Dec 1
> rewrote function in fona_modem that calls Circuits.UART.read (fona_modem repo)
> https://www.erlang.org/doc/design_principles/statem#choosing-the-callback-mode
> The short version: choose state_functions

Fri Dec 8
> Got CellStateMachine working with a few different states and state changes

Sat Dec 9
> ?

Sun Dec 10, 2023
> Registering the servers with names.  Had some luck getting servers to start up/initialize

Mon Dec 11
> Fixed name registration.  Client API calls on CellStateMachine work now.

Tue Dec 12
> ?
>
tone 11 is off hook warning
https://cdn-shop.adafruit.com/datasheets/SIMCOM_SIM5320_ATC_EN_V2.02.pdf

Wed Dec 13
> FonaModem: Added play_tone, distinct from play_ext_tone.
> Fixed handling of partial response from UART.read.
> CellStateMachine is able to control FonaModem
> Added play_tone function that plays sounds of digits
> Also have play_ext_tone for sounds like dial tones, off hook warning, system busy

Fri Dec 15
> ?

### TODO
* Revisit the way KeyPad creates a GenServer as the client
* complete the cycle of making a phone call - with GSM?
* solder speaker connector
* Add timeout to get to off hook warning state
* Need to have Keypad trigger state changes
* Change casts to calls for state machine to show caller what happened
* Make fona_modem a shared dependency on gitub
* add fona support for incoming call
* add state flow for incoming call
* add support for incoming SMS
* add support for outgoing SMS
* change gpio version in FONA.  Don't need to use the one that keypad uses

### Questions

### How should it work?
* need a button for hanging up.  Physical button or use # on keypad? <- use #
* need a button to answer incoming calls.  Physical button or use * on keypad? <- use *

* Add speakerphone
* bluetooth handset support or nah?
* Add physical buttons for volume up/down?
* Add physical buttons for pick up/hang up?
* open source fona_modem?  release on hex.pm?
