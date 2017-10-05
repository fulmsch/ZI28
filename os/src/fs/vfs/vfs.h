.define fileTableMode        0                        ;1 byte
.define fileTableRefCount    fileTableMode + 1        ;1 byte
.define fileTableDriveNumber fileTableRefCount + 1    ;1 byte
.define fileTableDriver      fileTableDriveNumber + 1 ;2 bytes
.define fileTableOffset      fileTableDriver + 2      ;4 bytes
.define fileTableSize        fileTableOffset + 4      ;4 bytes
                                                      ;-------
                                                ;Total 13 bytes
.define fileTableData        fileTableSize + 4  ;Max   19 bytes


.define file_read  0
.define file_write 2
