# ZI-28 Emulator

This emulator can be used to test and debug software for the ZI-28. It creates
a pseudo-terminal at `/tmp/zi28sim`, which behaves like the USB-serial port of
the real ZI-28.

## Building

Make sure you have gtk3, glade, and libz80 installed. Then simple type `make`
to build the emulator. The target `make install` copies the executable to
`/usr/local/bin/`.

## Usage

The emulator can be invoked with the following command line arguments:

* -t, --text-mode: Launch without the graphical interface.
* -r, --rom-file: Specify a binary file that is loaded into the simulated
  EEPROM. Alternatively, you can load a file from the graphical interface.
* -s, --silent: Don't write anything to stdout.

