;; 
.list
;TODO consolidate error returns

.define fileTableStatus     0
.define fileTableDriver     fileTableStatus + 1
.define fileTableAttributes fileTableDriver + 2
.define fileTableOffset     fileTableAttributes + 1
.define fileTableSize       fileTableOffset + 4
.define fileTableMode       fileTableSize + 4
.define fileTableData       fileTableMode + 1

;.define fileTableDrive         fileTableMode + 1
;.define fileTableStartCluster  fileTableAttributes + 1
;.define fileTableSize          fileTableStartCluster + 2

.define file_read  0
.define file_write 2
;.define file_seek  4
.define file_fctl   4

.define REG_FILE  1
.define CHAR_DEV  2
.define BLOCK_DEV 3

.define SEEK_SET  0
.define SEEK_PCUR 1
.define SEEK_NCUR 2
.define SEEK_END  3

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
;; : [getTableAddr](drive.asm#getTableAddr)

	ld hl, fileTable
	ld de, fileTableEntrySize
	ld b, fileTableEntries
	jp getTableAddr
.endf ;getFileAddr



.func k_open:
;; Open a file / device file
;;
;; Creates a new file table entry and returns the corresponding fd
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

;TODO convert path to uppercase
;TODO set offset to 0
	ld (k_open_mode), a
	ld (k_open_path), de

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
	ld (k_open_fd), a

	;path should begin with "n:", where 0 <= n <= 9
	ld hl, (k_open_path)
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
	ld (k_open_drive), a
	inc hl
	inc hl
	ld (k_open_path), hl



	;ix points to free table entry
;	ld de, fileTableMode
;	add hl, de

	;search drive entry
	ld a, (k_open_drive)
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

	ld a, (k_open_mode)
	ld (ix + fileTableMode), a
	ld a, 0
	ld (ix + fileTableOffset + 0), a
	ld (ix + fileTableOffset + 1), a
	ld (ix + fileTableOffset + 2), a
	ld (ix + fileTableOffset + 3), a

	ld de, return
	push de
	ld de, (k_open_path)

	;FIX jumps to pointer
	jp (hl)

return:
	;TODO check for succesful call
	cp 0
	ret nz
	ld (ix + 0), 1


	ld a, (k_open_fd)
	ld e, a
	ld a, 0
	ret


invalidDrive:
	ld a, 2
	ret
invalidPath:
	ld a, 3
	ret

;mode:
	.db 0
;fd:
	.db 0
;path:
	.dw 0
;pathBuffer:
;	.resb 13
;sector:
;	.resb 4
;drive:
	.db 0

.endf ;k_open


.func k_close:
;; Close a file
;;
;; Closes a file and makes its fd available again
;;
;; Input:
;; : a - file descriptor
;;
;; Output:
;; : a - errno
;Errors: 0=no error
;        1=invalid file descriptor

	call getFileAddr
	jr c, invalidFd

	ld a, 0
	ld b, fileTableEntrySize
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

	;check if block device, else call file driver
	ld a, (ix + fileTableStatus)
	cp BLOCK_DEV
	jp z, block_read
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
	ld a, 0
	ld de, 0
	ret
;buffer:
;	.dw 0
;count:
;	.dw 0
.endf ;k_read


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
	call getFileAddr
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
	ld a, 0
	ld de, 0
	ret
.endf ;k_write


.func k_seek:
;; Change the file offset of an open file
;;
;; The new offset is calculated according to whence as follows:
;;
;; * `SEEK_SET` : from start of file
;; * `SEEK_PCUR` : from current location in positive direction
;; * `SEEK_NCUR` : from current location in negative direction
;; * `SEEK_END` : from end of file in negative direction
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

	push hl
	push de

	;check if fd exists, get the address
	call getFileAddr
	pop de
	pop bc
	jp c, invalidFd
	ld a, (hl)
	cp 00h
	jp z, invalidFd
	;hl=table entry addr

	push de
	push hl

	;check whence
	ld a, b
	cp SEEK_SET
	jr z, set
	cp SEEK_END
	jr z, end
	cp SEEK_PCUR
	jr z, pcur
	cp SEEK_NCUR
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
	call sub32

	pop hl ;table entry addr

	ld de, fileTableOffset
	add hl, de
	push hl
	ld de, k_seek_new
	call ld32

	pop de
	ld a, 0
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

	pop hl ;table entry addr
	push hl
	ld de, fileTableSize
	add hl, de
	ex de, hl
	ld hl, k_seek_new
	call cp32
	pop hl
	jr nc, invalidOffset

	ld de, fileTableOffset
	add hl, de
	push hl
	ld de, k_seek_new
	call ld32

	pop de
	ld a, 0
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
