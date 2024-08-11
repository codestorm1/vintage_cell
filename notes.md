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

Mon Dec 18
> Fixed tone playing
> Pressing * takes the phone off hook, dialing a number works and plays tones.
> KeyPad Dialer now calls into CellStateMachine, which calls FonaModem

Sometime:
> Soldered speaker connector

Execute minicom -D /dev/ttyS0 (ttyS0 is the serial port of Raspberry Pi 3B/3B+/4B).
Default baud rate is 115200
Raspberry Pi 2B/zero, the user serial device number is ttyAMA0, and the Raspberry Pi 3B/3B+/4B serial device number is ttyS0.

Sun Dec 31, 2023
> Bailed on FONA 3G, 3G service is dying fast
> Switched to WaveShare 4G hat
> Figured out the UART to USB jumpers on the Waveshare baord
> Installed Windows and Mac drivers from https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers
> WaveShare hat is responding to AT commands
> NervesCell is able to dial, hang up, using WaveShare

Sat Jan 6, 2024
> Switched CellStateMachine to use calls instead of casts
> Fixed hanging up calls - CellStateMachine was missing a call to fona to hang up

Feb 9, 2024
> Updated these notes

Previous to Tue Feb 27, 2024
> Designed and built a circuit to let a GPIO ring a bell - works great!

Tue Feb 27, 2024
> write proposal - submitted!

Sat, Mar 2, 2024
> Pulled out KeypadDialer and Keypad dep, going all in on rotary.  Should be made to be easily swappable with Rotary Dialer
> Discovered that my 3G service was dead.  Had to order a new SIM card that supports 4G and up.

Sun, Mar 3, 2024
> Test monophone headset with nokia phone and adapter jack <- done
> Got Monophone headset hooked up to WaveShare.  
> The headset is now wired to a plug you can hook into any device that has a 3.5mm jack, including the WaveShare modem.

Wed, Mar 6, 2024
> Added resistors and wire harness connection to vintage phone.  
> Added phone_hook_server to nerves cell from vintage cell
> Tested on/off hook and dialing.  Both are working!
> Get rotary dialing and hook to work again - done, although dialing is spotty now
> how to attach dialer and hook wires to RPi? - done, hooked up to proto board
> added JST connecters and pin headers to the bell ringer proto board, for dial/hook connectors

Sat, Mar 9, 2024
> Detecting incoming calls.  CellStateMachine registers to get incoming_ring events from the WaveshareModem and changes state accordingly

Sun, Mar 10, 2024
> nerves_cell: Write code to handle message of incoming call.  Ring bell, change state to incoming_ring
  handle incoming_ring_stopped, timeout bell <- done
> Got the ringing figured out using the RI pin as a GPIO input
> The ring happens, 4 seconds pass, and it stops ringing/starts ringing again.  The timing works out with a 2 second ring/2 second pause. 
> Got actual incoming calls to ring the bell and picking up the phone answers the call

Mon, Mar 11, 2024
> Didn't get a spot at NervesConf2024
> Maybe do YouTube

Thu May 16, 2024
> 2 months passed? Mostly worked on 3D printed MonoPhone/WaveShare case
> Tested phone inside MonoPhone, built by Intel Mac.  Modem wasn't responding, going back to ARM mac.
> Some code hadn't been checked in, maybe issue was repo being out of date.

Sat May 25, 2024
> Got accepted to ElixirConf!
> Latest 3D print of case looks good to go

Sun May 26, 2024
> Trying to make a change so that two different dev machines can be used
> Used multiple authorized keys, that worked.

Fri May 31, 2024
> tightened up wiring a bit, ordered wire clips

Previous
> Made sample projects neo and pixel to try out blinkchain package for lighting up neopixels
> Got a sample project to work, lighting up the NeoPixel strip in different colors
> There are crashes the need looking into (Blinkchain.HAL timeout)

Sat June 15, 2024
> Glued Neopixel strip into MonoPhone, hooked up connections to RPi
> Added config for neopixels/blinkchain
> Added LEDServer genserver to manage neopixels

Sat June 23, 2024
> 8 LEDs are using too much power


Sat July 6, 2024
> previously printed case that has vertical lipo charger holder
> ordered a new audio cable with pigtail.  Current one is big and hard to place inside phone

Sun July 7, 2024
> ?

Sat July 20, 2024
> previously soldered new usb-mini pigtail and fixed up some other wiring
> progress on presentation

Wed Jul 24, 2024
> soldered resistors to the Adafruit lipo chargers to increase charging rate hopefully
> put phone together for testing.  
> dialed my cellphone, had a successful call


Sun Aug 11, 2024
> Previously - discovered that the vintage cord turned into USB was not allowing for a good charge
> Ordered USB A cord with pigtail end to replace vintage cord

> Built new prototype board to be a HAT
* need to change gpio pins, a couple pins changed.  

* make a livebook
* get the circuitry reviewed

* try bigger waveshare antennea
* need to test phone

* bell isn't ringing for incoming call

## Get this thing ready for presentation!

### Vintage phone


* Adafruit lipoly Charger LEDs are available as output pins

Code:
* make some other tones instead of dial tone
* make use of D6 pin to turn modem on and off
* get the volume up - check out the modem's WaveSahre wiki
* dialing detection is off, fix it - (maybe only when not pausing between digits?)

Physical:
* pin arrangement is too fragile, use right angle male headers
* tighten up wiring inside
* ok to power RPi0 with 3.7V lipo battery?

Bonus:
* status neopixel?
* Add timeouts in state machine
* Get dial tone and network busy sounds to play
* Turn fona_modem into AT modem.  Move any params to init method, not config
* put state into structs
* charge both batteries from usb
√ Wire and fit everything into MonoPhone
√ fona_modem: detect call and let client know
√ Fit bell and battery
√ Make the cord work as a USB charger
√ Add charger for WaveShare - just use an add-on board
√ Design and print bigger case to hold waveshare
√ build bell-ringer into a proper PCB
√ Waveshare doesn't make a ringing noise for incoming calls - ring bell.
√ build circuit to ring bell from Rasp Pi (breadboarD)
√ Ordered 2N2222 transistor, 18650 battery with charger and clip. Thanks ChatGPT
√ solve 3 wire problem - solved! was never a problem?  joining mic and speaker negatives- works
√ add state flow for incoming call
√ add support for incoming call

### TODO
* rename fona_modem to... at_modem? waveshare_modem now
* Make fona_modem a shared dependency on gitub
* add support for incoming SMS
* add support for outgoing SMS

* determine if UART is in sync; if AT commands are responding to the current command
* reset modem if not in sync? recover somehow
* Maduino Zero 4G LTE(SIM7600X)?
* fona modem - add functions for loudspeaker on/off (Waveshare HAT has no loudpseaker)
* Add timeout to get to off hook warning state (can't play that panic tone, no point doing this)

### FONA replacement Features
* Audio jack or audio output
* Makes ring sound when call is incoming
* Play extended tones - dial tone, fast busy
* Ring indicator pin
* Network pin
* Shows battery level in response to AT+CBC, not just voltage

### How keypad based phone could work
* change circuits.gpio version in FONA.  Don't need to use the one that keypad uses
* need a button for hanging up.  Physical button or use # on keypad? <- use #
* need a button to answer incoming calls.  Physical button or use * on keypad? <- use *
* Add speakerphone
* bluetooth handset support or nah?
* Add physical buttons for volume up/down?
* Add physical buttons for pick up/hang up?
* open source fona_modem?  release on hex.pm?

Waveshare: (3GPP TS 27.007, 27.005, and V.25TER command set)

Bell mount size 94.53mm x 63.74
