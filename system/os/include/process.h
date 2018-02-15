IFNDEF PROCESS_H
DEFINE PROCESS_H

INCLUDE "memmap.h"

DEFC process_fdTableEntries = 8

DEFC process_registerSave_top = ram_user_top
DEFC process_registerSave = process_registerSave_top - 12
DEFC process_fdTable = process_registerSave - process_fdTableEntries
DEFC process_argv_top = process_fdTable

ENDIF
