.list
;*********** File Table ********************
;.define fileTableEntrySize  32
;.define fileTableEntries    32

;fileTable:
;	.resb fileTableEntrySize * fileTableEntries


.define fileTableStatus     0
.define fileTableDriver     fileTableStatus + 1
.define fileTableAttributes fileTableDriver + 2
.define fileTableOffset     fileTableAttributes + 1
.define fileTableMode       fileTableOffset + 4
.define fileTableData       fileTableMode + 1

;.define fileTableDrive         fileTableMode + 1
;.define fileTableStartCluster  fileTableAttributes + 1
;.define fileTableSize          fileTableStartCluster + 2

.define file_read  0
.define file_write 2
.define file_seek  4
.define file_fctl   6

.func getFileAddr:
;Inputs: a = index
;Outputs: hl = table entry address
;Errors: c = out of bounds
;        nc = no error

	ld hl, fileTable
	ld de, fileTableEntrySize
	ld b, fileTableEntries
	jp getTableAddr
.endf ;getFileAddr



;*****************
;Open file
;Description: creates a new file table entry
;Inputs: (de) = pathname, a = mode
;Outputs: e = file descriptor, a = errno
;Errors: 0=no error
;        1=maximum allowed files already open
;        2=invalid drive number
;        3=invalid path
;        4=no matching file found
;        5=file too large
;Destroyed: all
.func k_open:
;TODO convert path to uppercase
	ld (mode), a
	ld (path), de

	;search free table spot
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
	ld a, 1
	ret

tableSpotFound:
	ld a, c
	ld (fd), a
	;TODO check if valid path
	;path should begin with "n:", where 0 <= n <= 9
	ld hl, (path)
	inc hl
	ld a, (hl)
	dec hl
	cp ':'
	jr nz, invalidPath
	ld a, (hl)
	sub '0'
	jp c, invalidPath
	cp 10
	jp nc, invalidPath
	ld (drive), a
	inc hl
	inc hl
	ld (path), hl



	;ix points to free table entry
;	ld de, fileTableMode
;	add hl, de

	;search drive entry
	ld a, (drive)
	call getDriveAddr
	jr c, invalidDrive

	ld de, driveTableFsdriver
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl ;(hl) = Fsdriver
;	push hl
;	pop ix


;driveFound:
;	ld l, (ix + driveTableFsdriver)
;	ld h, (ix + driveTableFsdriver + 1)
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
;	pop bc ;filetable entry addr

	ld a, (mode)
	ld (ix + fileTableMode), a

	ld de, return
	push de
	ld de, (path)

	;FIX jumps to pointer
	jp (hl)

return:
	;TODO check for succesful call
	cp 0
	ret nz
	ld (ix + 0), 1


	ld a, (fd)
	ld e, a
	ld a, 0
	ret


invalidDrive:
	ld a, 2
	ret
invalidPath:
	ld a, 3
	ret

mode:
	.db 0
fd:
	.db 0
path:
	.dw 0
;pathBuffer:
;	.resb 13
;sector:
;	.resb 4
drive:
	.db 0

.endf ;k_open

;*****************
;Close file
;Description: close a file table entry
;Inputs: a = file descriptor
;Outputs: a = errno
;Errors: 0=no error
;        1=invalid file descriptor
;Destroyed: none
.func k_close:
	cp fileTableEntries
	jr nc, invalidFd

	call getFileAddr
	jr c, invalidFd


entryFound:
	ld a, 0
clearEntry:
	ld (hl), a
	inc hl
	djnz clearEntry

	ld a, 0
	ret

invalidFd:
	ld a, 1
	ret
.endf ;k_close


;*****************
;Read from file
;Description: copy data from a file to memory
;Inputs: a = file descriptor, (de) = buffer, hl = count
;Outputs: a = errno, de = count
;Errors: 0=no error
;        1=invalid file descriptor
;        2=invalid file driver
;Destroyed: none
.func k_read:
	push de ;buffer
	push hl ;count
;	ld (buffer), de
;	ld (count), hl

	;check if fd exists
	call getFileAddr
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

	;call file driver
	pop bc ;count
	pop de ;buffer
;	ld bc, (count)
;	ld de, (buffer)
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
;buffer:
;	.dw 0
;count:
;	.dw 0
.endf ;k_read


.func k_write:

.endf ;k_write


.func k_seek:

.endf
