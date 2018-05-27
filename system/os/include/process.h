IFNDEF PROCESS_H
DEFINE PROCESS_H

INCLUDE "memmap.h"

DEFC process_fdTableEntries = 8

DEFC process_max_argc = 16
DEFC process_max_args_length = 128


DEFC process_dataSection = 0x8000
DEFC process_argString   = 0x8080
DEFC process_argVector   = process_argString - ((process_max_argc * 2) + 2)
DEFC process_registerSave = process_argVector - 12
DEFC process_fdTable = process_registerSave - process_fdTableEntries

ENDIF
