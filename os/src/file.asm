;; 
.list
;TODO consolidate error returns

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
.define file_fstat 4
;.define file_fctl  4



.func getFileAddr:
;; Finds the file entry of a given fd
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : hl - table entry address
;; : carry - out of bounds
;; : nc - no error
;;
;; See also:
;; : [getTableAddr](drive.asm.html#getTableAddr)

	;TODO optimise by using an aligned table and bitshifts

	ld hl, fileTable
	ld de, fileTableEntrySize
	ld b, fileTableEntries
	jp getTableAddr
.endf


.func fdToFileEntry:
;; Finds the file entry of a given fd
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : hl - table entry address
;; : carry - error
;; : nc - no error


	call getFdAddr
	ret c
	ld a, (hl)
	;a = file table index
	jp getFileAddr

error:
	scf
	ret
.endf

.func getFdAddr:
;; Get the address of a file descriptor
;;
;; Input:
;; : a - fd
;;
;; Output:
;; : hl - fd address
;; : carry - error
;; : nc - no error
;;
;; Destroyed:
;; : a, hl, de

	;check if fd in range
	cp fdTableEntries*2
	jr nc, error

	ld hl, k_fdTable
	;a = fd
	;hl = fd table base addr
	ld d, 0
	ld e, a
	add hl, de ;this should reset the carry flag
	ret

error:
	scf
	ret
.endf


.func u_open:
	ld hl, u_fdTable
	ld c, fdTableEntries
	call open
	; e -= fdTableEntries
	push af
	ld a, e
	sub fdTableEntries
	ld e, a
	pop af
	ret
.endf

k_open:
;; Open a file / device file
;;
;; Creates a new file table entry and returns the corresponding fd
;;
;; Exactly one of the following flags must be set:
;;
;; * `O_RDONLY` : Open for reading only.
;; * `O_WRONLY` : Open for writing only.
;; * `O_RDWR` : Open for reading and writing.
;;
;; Additionally, zero or more of the following flags may be specified:
;; (PLANNED)
;;
;; * `O_APPEND` : Before each write, the file offset is positioned at the
;; end of the file.
;; * `O_DIRECTORY` : Causes open to fail if the specified file is not a
;; directory.
;; * `O_TRUNC` : If the file exists and opened for writing, its size gets
;; truncated to 0.
;;
;; Before calling the filesystem routine, the mode field gets populated with
;; the requested access mode. The filesystem routine should return with an
;; error if the required permissions are missing. On success it should bitwise
;; OR the filetype with the mode.
;;
;; Input:
;; : (de) - pathname
;; : a - mode
;;
;; Output:
;; : e - file descriptor
;; : a - errno
;Errors: 0=no error
;        1=maximum allowed files already open
;        2=invalid drive number
;        3=invalid path
;        4=no matching file found
;        5=file too large

	ld hl, k_fdTable
	ld c, 0

.func open:
;; Input:
;; : hl - base address of fd-table
;; : c - base fd
;; : (de) - pathname
;; : a - mode
;;
;; Output:
;; : e - file descriptor
;; : a - errno


;TODO convert path to uppercase
	ld (k_open_mode), a
	ld (k_open_path), de

	ld a, 0xff
	ld b, fdTableEntries
fdSearchLoop:
	cp (hl)
	jr z, fdFound
	inc c
	inc hl
	djnz fdSearchLoop

	;no free fd
	ld a, 0xe0 ;TODO errno
	ret

fdFound:
	ld a, c
	ld (k_open_fd), a

	;search free file table spot
	ld ix, fileTable
	ld b, fileTableEntries
	ld c, 0
	ld de, fileTableEntrySize

tableSearchLoop:
	ld a, (ix + 0)
	cp 00h
	jr z, tableSpotFound
	add ix, de
	inc c
	djnz tableSearchLoop

	;no free spot found, return error
	ld a, 0xf0 ;TODO errno
	ret

tableSpotFound:
	ld a, c
	ld (k_open_fileIndex), a


	ld hl, (k_open_path)
	call realpath

	inc hl
	ld d, h
	ld e, l
	;(de) = drive label

fullPathSplitLoop:
	inc hl
	ld a, (hl)
	cp 0x00
	jr z, rootDir
	cp '/'
	jr nz, fullPathSplitLoop

	xor a
	ld (hl), a ;terminate drive name
	inc hl
rootDir:
	;(hl) = absolute path
	ld (k_open_path), hl


	;(de) = drive label
	ld c, driveTableEntries
	ld hl, driveTable

findDriveLoop:
	push de ;drive label
	push hl ;drive entry

	call strcmp
	jr z, findDriveCmpEnd

findDriveCmpFail:
	pop hl ;drive entry
	ld de, driveTableEntrySize
	add hl, de
	pop de ;drive label

	dec c
	jr nz, findDriveLoop

	;drive not found
	ld a, 0xf3
	ret

findDriveCmpEnd:
	ld a, (de)
	cp '/'
	jr z, driveFound
	cp 0x00
	jr nz, findDriveCmpFail

driveFound:
	pop hl ;drive entry
	pop de ;clear the stack
	;(hl) = drive entry

	;calculate the drive number
	;c = driveTableEntries - driveNumber
	;=> driveNumber = driveTableEntries - c
	ld a, driveTableEntries
	sub c
	ld (k_open_drive), a
	
	ld de, driveTableFsdriver
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl ;(hl) = Fsdriver

	and a
	ld de, 0
	sbc hl, de
	jr z, invalidDrive;NULL pointer
	ld de, fs_open
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	;store requested permissions
	ld a, (k_open_mode)
	ld b, a
	xor a
	bit O_RDONLY_BIT, b
	jr nz, skipWriteFlag
	ld a, M_WRITE
skipWriteFlag:
	bit O_WRONLY_BIT, b
	jr nz, skipReadFlag
	or M_READ
skipReadFlag:
	ld (ix + fileTableMode), a


	ld a, (k_open_drive)
	ld (ix + fileTableDriveNumber), a
	xor a
	ld (ix + fileTableOffset + 0), a
	ld (ix + fileTableOffset + 1), a
	ld (ix + fileTableOffset + 2), a
	ld (ix + fileTableOffset + 3), a

	push ix
	ld de, return
	push de
	ld de, (k_open_path)

	jp (hl)

return:
	pop ix
	cp 0
	jr nz, error

	ld a, (k_open_mode)
	bit O_DIRECTORY_BIT, a
	jr z, success
	;check if directory
	ld a, (ix + fileTableMode)
	bit M_DIR_BIT, a
	jr z, error ;not a directory

success:
	ld (ix + fileTableRefCount), 1
	ld a, (k_open_fileIndex)
	push af ;file index
	ld a, (k_open_fd)
	push af ;fd
	call getFdAddr
	pop af ;fd
	ld e, a
	pop af ;file index
	ld (hl), a
	xor a
	ret

error:
	;error, clear the file entry
	ld (ix + fileTableMode), 0
	ld a, 1
	ret


invalidDrive:
	ld a, 0xf4
	ret
invalidPath:
	ld a, 0xf5
	ret

.endf


u_close:
	add a, fdTableEntries

.func k_close:
;; Close a file
;;
;; Closes a file descriptor. If the file has no more references, it gets closed too.
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : a - errno
;Errors: 0=no error
;        1=invalid file descriptor

	call getFdAddr
	jr c, invalidFd
	ld a, (hl)
	;check if fd exists
	cp 0xff
	jr z, invalidFd
	ld (hl), 0xff
	call getFileAddr

	inc hl
	dec (hl)
	ret nz ;more references to the file
	dec hl

	xor a
	ld b, fileTableEntrySize
clearEntry:
	ld (hl), a
	inc hl
	djnz clearEntry

	xor a
	ret

invalidFd:
	ld a, 1
	ret
.endf ;k_close


.func u_dup:
	ld hl, u_fdTable
	ld c, fdTableEntries
	call dup
	; e -= fdTableEntries
	push af
	ld a, e
	sub fdTableEntries
	ld e, a
	pop af
	ret
.endf

k_dup:
;; Duplicate a file descriptor.
;;
;; If `new fd` is equal to 0xFF, the next free file descriptor will be used.
;;
;; Input:
;; : a - new fd
;; : b - old fd
;;
;; Output:
;; : a - errno
;; : e - new fd

	ld hl, k_fdTable
	ld c, 0

.func dup:
;; Input:
;; : a - new fd
;; : b - old fd
;; : hl - base address of fd-table
;; : c - base fd
;;
;; Output:
;; : a - errno
;; : e - new fd

	push af
	ld a, b
	ld (k_dup_oldFd), a
	pop af

	cp 0xff
	jr nz, newSpecified

	ld a, 0xff
	ld b, fdTableEntries
fdSearchLoop:
	cp (hl)
	jr z, newFdFound
	inc c
	inc hl
	djnz fdSearchLoop

	jr error

newFdFound:
	ld a, c
	ld (k_dup_newFd), a
	jr copyFd

newSpecified:
	ld (k_dup_newFd), a
	call getFdAddr
	jr c, error
	ld a, (hl)
	cp 0xff
	jr z, copyFd
	call k_close

copyFd:
	ld a, (k_dup_newFd)
	call getFdAddr
	push hl
	ld a, (k_dup_oldFd)
	call getFdAddr
	pop de
	jr c, error
	;de - new fd, hl - old fd
	ld a, (hl)
	ld (de), a

	;inc reference count
	ld a, (hl)
	call getFileAddr
	inc hl
	inc (hl)

	ld a, (k_dup_newFd)
	ld e, a

	xor a
	ret

error:
	ld a, 1
	ret
.endf


.func udup:
;; Copy a kernel file descriptor to the user fd-table.
;;
;; If the user fd already exists, it will stay the same.
;;
;; Input:
;; : a - user fd
;; : b - kernel fd
;;
;; Output:
;; : a - errno

	push af
	ld a, b
	call getFdAddr
	jr c, error
	;hl = kernel fd addr
	pop af ;user fd
	add a, fdTableEntries
	push hl ;kernel fd addr
	call getFdAddr
	jr c, error
	pop de ;kernel fd addr
	;hl = user fd addr

	;check if user fd already exists
	ld a, (hl)
	cp 0xff
	ld a, 0
	ret nz

	;copy fd
	ld a, (de)
	ld (hl), a
	;inc reference count
	call getFileAddr
	inc hl
	inc (hl)

	xor a
	ret


error:
	pop af
	ld a, 1
	ret

.endf


u_readdir:
	add a, fdTableEntries

.func k_readdir:
;; Get information about the next file in a directory.
;;
;; Input:
;; : a - dirfd
;; : (de) - stat
;;
;; Output:
;; : a - errno

	push af
	push de

	;check if fd exists
	call fdToFileEntry
	jr c, invalidFd
	ld a, (hl)
	cp 00h
	jr z, invalidFd

	push hl
	pop ix

	;check if dirfd is a directory
	ld a, (ix + fileTableMode)
	and M_DIR
	jr z, error ;not a directory

	;check for valid file driver
	;get the drive table entry of the filesystem
	ld a, (ix + fileTableDriveNumber)
	call getDriveAddr
	jp c, error ;drive number out of bounds
	;(hl) = driveTableEntry
	ld de, driveTableFsdriver
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	;de = fsdriver
	ld hl, 0
	or a
	sbc hl, de
	jr z, error ;driver null pointer
	ld hl, fs_readdir
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	;(hl) = routine

	pop de ;stat
	pop af ;fd

	jp (hl)

invalidFd:
error:
	pop de
	pop de
	ld a, 1
	ret

.endf


u_stat:

.func k_stat:
;; Get information about a file.
;;
;; Input:
;; : (de) - filename
;; : (hl) - stat
;;
;; Output:
;; : a - errno

	push hl
	ld a, O_RDONLY
	call k_open
	cp 0
	ld a, e
	pop de ;stat
	ret nz

	push af
	call k_fstat
	pop af
	jp k_close
.endf


u_fstat:
	add a, fdTableEntries

.func k_fstat:
;; Get information about an open file.
;;
;; Input:
;; : a - fd
;; : (de) - stat
;;
;; Output:
;; : a - errno

	push de ;buffer

	;check if fd exists
	call fdToFileEntry
	jr c, error ;invalidFd
	ld a, (hl)
	cp 00h
	jr z, error ;invalidFd

	push hl
	pop ix

	;check for valid file driver
	ld l, (ix + fileTableDriver)
	ld h, (ix + fileTableDriver + 1)
	and a
	ld de, 0
	sbc hl, de
	jr z, error ;invalidDriver;NULL pointer
	ld de, file_fstat
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	pop de ;buffer

	jp (hl)

error:
	pop de
	ld a, 1
	ret
.endf


u_read:
	add a, fdTableEntries

.func k_read:
;; Read from an open file
;;
;; Finds and calls the read routine of the corresponding file driver.
;;
;; Input:
;; : a - file descriptor
;; : (de) - buffer
;; : hl - count
;;
;; Output:
;; : de - count
;; : a - errno
;Errors: 0=no error
;        1=invalid file descriptor

	;TODO limit count to size-offset
	;TODO check permission

	push de ;buffer
	push hl ;count
;	ld (buffer), de
;	ld (count), hl

	;check if fd exists
	call fdToFileEntry
	jr c, invalidFd
	ld a, (hl)
	cp 00h
	jr z, invalidFd

	push hl
	pop ix
;	ld de, fileTableFiledriver
;	add ix, de

	;check for valid file driver
	ld l, (ix + fileTableDriver)
	ld h, (ix + fileTableDriver + 1)
	and a
	ld de, 0
	sbc hl, de
	jr z, invalidDriver;NULL pointer
	ld de, file_read
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	pop bc ;count
	pop de ;buffer

	;check if count > 0
	ld a, b
	cp 0
	jr nz, validCount
	ld a, c
	cp 0
	jr z, zeroCount
validCount:
	push ix
	;push return address to stack
	push hl
	ld hl, return
	ex (sp), hl

	jp (hl)

return:
	pop ix
	push de
	;add count to offset
	ld hl, regA
	call ld16 ;load count into reg32
	ld d, h
	ld e, l

	ld b, ixh
	ld c, ixl
	ld hl, fileTableOffset
	add hl, bc
	call add32

	pop de ;count
	xor a
	ret

invalidFd:
	pop hl
	pop hl
	ld a, 1
	ret
invalidDriver:
	pop hl
	pop hl
	ld a, 2
	ret
zeroCount:
	xor a
	ld de, 0
	ret
;buffer:
;	.dw 0
;count:
;	.dw 0
.endf ;k_read


u_write:
	add a, fdTableEntries

.func k_write:
;; Write to an open file
;;
;; Finds and calls the write routine of the corresponding file driver.
;;
;; Input:
;; : a - file descriptor
;; : (de) - buffer
;; : hl - count
;;
;; Output:
;; : de - count
;; : a - errno
; Errors: 0=no error
;         1=invalid file descriptor
;         2=invalid file driver

	push de ;buffer
	push hl ;count

	;check if fd exists
	call fdToFileEntry
	jr c, invalidFd
	ld a, (hl)
	cp 00h
	jr z, invalidFd

	push hl
	pop ix

	;check for valid file driver
	ld l, (ix + fileTableDriver)
	ld h, (ix + fileTableDriver + 1)
	and a
	ld de, 0
	sbc hl, de
	jr z, invalidDriver;NULL pointer
	ld de, file_write
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	pop bc ;count
	pop de ;buffer

	;check if count > 0
	ld a, b
	cp 0
	jr nz, validCount
	ld a, c
	cp 0
	jr z, zeroCount
validCount:

	;call file driver
	jp (hl)

invalidFd:
	pop hl
	pop hl
	ld a, 1
	ret
invalidDriver:
	pop hl
	pop hl
	ld a, 2
	ret
zeroCount:
	xor a
	ld de, 0
	ret
.endf ;k_write




.func u_lseek:
	add a, fdTableEntries
	jp k_lseek
.endf

u_seek:
	add a, fdTableEntries

k_seek:
;; Change the file offset of an open file using a 16-bit offset.
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `K_SEEK_SET` : from start of file
;; * `K_SEEK_PCUR` : from current location in positive direction
;; * `K_SEEK_NCUR` : from current location in negative direction
;; * `K_SEEK_END` : from end of file in negative direction
;;
;; Input:
;; : a - file descriptor
;; : de - offset
;; : h - whence
;;
;; Output:
;; : (de) - new offset from start of file
;; : a - errno

	push hl
	ld hl, reg32
	call ld16
	ld d, h
	ld e, l
	pop hl


.func k_lseek:
;; Change the file offset of an open file using a 32-bit offset.
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `K_SEEK_SET` : from start of file
;; * `K_SEEK_PCUR` : from current location in positive direction
;; * `K_SEEK_NCUR` : from current location in negative direction
;; * `K_SEEK_END` : from end of file in negative direction
;;
;; Input:
;; : a - file descriptor
;; : (de) - offset
;; : h - whence
;;
;; Output:
;; : (de) - new offset from start of file
;; : a - errno
; Errors: 0=no error
;         1=invalid file descriptor
;         2=whence is invalid
;         3=the resulting offset would be invalid

	push hl ;h = whence
	push de ;offset

	;check if fd exists, get the address
	call fdToFileEntry
	pop de ;offset
	pop bc ;b = whence
	jp c, invalidFd
	ld a, (hl)
	cp 00h
	jp z, invalidFd
	;hl=table entry addr

	push hl ;table entry
	push de ;offset

	;check whence
	ld a, b
	cp K_SEEK_SET
	jr z, set
	cp K_SEEK_END
	jr z, end
	cp K_SEEK_PCUR
	jr z, pcur
	cp K_SEEK_NCUR
	jr nz, invalidWhence

ncur:
	ld de, fileTableOffset
	add hl, de
	ld de, k_seek_new
	call ld32
	jr subOffs

end:
	ld de, fileTableSize
	add hl, de
	ld de, k_seek_new
	call ld32

subOffs:
	;new=new-offs
	ld hl, k_seek_new
	pop de ;offset
	push de
	call cp32
	pop de
	jr c, invalidOffset

	ld hl, k_seek_new
	ex de, hl
	call sub32

	pop hl ;table entry addr

	ld de, fileTableOffset
	add hl, de
	push hl
	ld de, k_seek_new
	call ld32

	pop de
	xor a
	ret


pcur:
	ld de, fileTableOffset
	add hl, de
	ld de, k_seek_new
	call ld32
	jr addOffs

set:
	ld hl, k_seek_new
	call clear32

addOffs:
	;new=new+offs
	ld hl, k_seek_new
	pop de ;offset
	call add32

	pop hl ;table entry
	push hl
	ld de, fileTableSize
	add hl, de
	ex de, hl
	ld hl, k_seek_new
	call cp32
	pop hl
	;TODO reenable size checking
	;jr nc, invalidOffset

	ld de, fileTableOffset
	add hl, de
	push hl
	ld de, k_seek_new
	ex de, hl
	call ld32

	pop de
	xor a
	ret


invalidFd:
	ld a, 1
	ret
invalidWhence:
	ld a, 2
	ret
invalidOffset:
	ld a, 3
	ret
.endf ;k_seek
