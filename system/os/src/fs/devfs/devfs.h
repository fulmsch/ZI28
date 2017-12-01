.define devfs_name         0
.define devfs_entryDriver  8
.define devfs_number      10
.define devfs_data        11

.define dev_fileTableDirEntry fileTableData             ;Pointer to entry in devfs
.define dev_fileTableNumber   dev_fileTableDirEntry + 2
.define dev_fileTableData     dev_fileTableNumber + 1
