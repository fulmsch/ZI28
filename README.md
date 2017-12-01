# ZI-28: An Expandable Z80 Microcomputer

The ZI-28 is my attempt at developing a Z80 based microcomputer.
The main goals were to have a system that's about as usable as
a personal computer of the 80s and easily expandable with additional hardware.

The project is still very much a work in progress. Both the hardware and the
OS are functional, but many planned features have yet to be implemented.

If you want to try out yourself what using the ZI-28 feels like, you can do so
with the included emulator. See the quick start guide for instructions.


## Quick start guide


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


## Prerequisites

TODO: document required software and configuration

naken_asm
libz80
gtk3
glade
z88dk
