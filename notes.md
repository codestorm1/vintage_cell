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

* Sun Nov 18, 2023
> Added a wire to the FONA-Pi board that I'm using for nerves cell - Grounded the FONA to the Pi.
> Able to reference FonaModem now as a local dependency
> Able to get the FONA to respond to AT commands
> Last time it booted, it was able to sync with AT modem commands and responses, although one response was ERROR 
> got FONA to make a call using IEx {:status, pid, _, _} = :sys.get_status(FonaModem)

### TODO:
* Get keypad to work
* Implement the finite state machine diagram as a GenStateMachine

* Make fona_modem a shared dependency on gitub
* open source it?  release on hex.pm? <- distant future

### How should it work?
* need a button for hanging up.  Physical button or use # on keypad? <- use #
* need a button to answer incoming calls.  Physical button or use * on keypad? <- use *

* support plug in handset
* add a speakerphone?
* bluetooth handset support or nah?

