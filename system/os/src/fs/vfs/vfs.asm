INCLUDE "vfs.h"

SECTION ram_fileTable
PUBLIC fileTable
fileTable:
	defs fileTableEntries * fileTableEntrySize

SECTION ram_fdTable
PUBLIC k_fdTable, u_fdTable
k_fdTable:
	defs fdTableEntries
u_fdTable:
	defs fdTableEntries
