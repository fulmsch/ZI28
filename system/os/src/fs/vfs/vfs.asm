INCLUDE "vfs.h"

SECTION bram_fileTable
PUBLIC fileTable
fileTable:
	defs fileTableEntries * fileTableEntrySize

SECTION bram_fdTable
PUBLIC k_fdTable, u_fdTable
k_fdTable:
	defs fdTableEntries
u_fdTable:
	defs fdTableEntries
