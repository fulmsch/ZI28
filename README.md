# ZI-28: An Expandable Z80 Microcomputer

The ZI-28 is my attempt at developing a Z80 based microcomputer.
The main goals were to have a system that's about as usable as
a personal computer of the 80s and easily expandable with additional hardware.

The project is still very much a work in progress. Both the hardware and the
OS are functional, but many planned features have yet to be implemented.

If you want to try out yourself what using the ZI-28 feels like, you can do so
with the included emulator. See the quick start guide for instructions.


## Prerequisites

It is assumed that you have a standard Linux develompent environment
(gcc, make, etc.) setup already. To build the emulator, you also need Gtk+
version 3.16 or higher and its development headers.

The Z80 software requires Z88DK v1.99B in order to be built. Make sure to have
all of the Z88DK binaries in your path. You don't need to worry about the ZCCCFG
environment variable; it gets set automatically by the Makefiles.

The emulator creates a pseudoterminal to simulate the serial connection of the
real computer. To access it, you will need a terminal emulator. For the easiest
experience, picocom should be installed, though you can also use any other one.


## Quick start guide

Ensure that you have all prerequisites installed. Type `make` to build the
entire project. You might be promted for your password to mount the filesystem
image. If the build completed successfully, type `make run`. This will open
the emulator with the newly built ROM- and SD-images and start picocom in your
current terminal window. Click the `continue`-button of the emulator to start
the system.


## Contents of this repository

* **emulator**: Based on libz80 by Gabriel Gambetta, this emulator simulates the
  Z80 processor and all the periphery of the ZI-28. It also includes some
  debugging features.
* **include**: Header files for the C library. These also form the interface to
  the operating system.
* **lib**: Library for compiling C code. Mostly copied from z88dk, but modified
  and expanded for the particularities of the ZI-28.
* **system**: Everything that's part of the machine itself, most notably the
  ROM-based operating system.
* **tools**: Utilities supporting the project.
* **user**: Various programs for the system.


## License

All code original to the ZI-28 project is licensed under the terms of the
GNU General Public License v3.0.
