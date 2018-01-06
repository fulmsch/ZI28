INCLUDE "block.h"

SECTION ram_os

PUBLIC block_buffer, block_curBlock, block_endBlock, block_remCount, block_totalCount
PUBLIC block_relOffs, block_readCallback, block_writeCallback, block_memPtr
block_buffer:        defs 512
block_curBlock:      defs   4
block_endBlock:      defs   4
block_remCount:      defs   2
block_totalCount:    defs   2
block_relOffs:       defs   2
block_readCallback:  defs   2
block_writeCallback: defs   2
block_memPtr:        defs   2
