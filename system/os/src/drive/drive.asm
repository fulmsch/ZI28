;; Contains routines for accessing drives

;*********** Drive Table ********************

#define driveTableChild    0                          ;1 byte
#define driveTableSibling  driveTableChild + 1        ;1 byte
#define driveTableDevfd    driveTableSibling + 1      ;1 byte
#define driveTableFsdriver driveTableDevfd + 1        ;2 bytes
                                                      ;-------
                                                ;Total 5 bytes
#define driveTableFsData   driveTableFsdriver + 2 ;Max 27 bytes

#define fs_init     0
#define fs_open     2
#define fs_close    4 ;not used yet
#define fs_readdir  6
#define fs_fstat    8
#define fs_unlink  10

#define driveTableEntrySize 32
#define driveTableEntries   8

#code ROM

addFsDriver:
;TODO implement


;TODO move to ram
;.align_bytes 16
fsDriverTable:
	DEFW devfs_fsDriver
	DEFW fat_fsDriver
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000
	DEFW 0x0000


getTableAddr:
;; Finds the file entry of a given fd
;;
;; Input:
;; : hl - table start address
;; : de - entry size
;; : b - maximum number of entries
;; : a - index
;;
;; Output:
;; : hl - table entry address
;; : carry - out of bounds
;; : nc - no error

#local
	cp 0x00
	ret z
	cp b
	jr nc, getTableAddr_invalid
getTableAddr_loop:
	add hl, de
	dec a
	jr nz, getTableAddr_loop
	;this should return c (error) if the loop wraps around (unconfirmed)
	ret

getTableAddr_invalid:
	scf
	ret
#endlocal


dummyRoot:
;; Create the root node of the filesystem.
	ld hl, driveTablePaths
	ld (hl), '/'
	inc l
	ld (hl), 0x00
	dec l
	dec h
	ld (hl), 0xff
	inc l
	ld (hl), 0xff
	inc l
	ld (hl), 0xff
	inc l
	ld (hl), 0x00
	inc l
	ld (hl), 0x00
	ret


mountRoot:
;; Populate the root node of the filesystem.
;;
;; Input:
;; : de - device name
;; : a - fs type

	push af
	ld a, O_RDWR
	call k_open
	pop hl ;h = fs type
	cp 0
	ret nz
	ld a, e ;fd
	ld d, h ;fs type
	ld ix, driveTable
	ld (ix + driveTableDevfd), a
	jp storeAndCallFsInit


storeAndCallFsInit:
;; Store and call the fs init routine
;;
;; Input:
;; : d - fs type
;; : ix - drive entry

#local
	ld a, 0x07
	and d
	add a, a ;a = offset in fs driver table
	ld de, fsDriverTable
	add a, e
	ld e, a ;(de) = fsDriver
	ex de, hl ;(hl) = fsDriver

	ld e, (hl)
	inc hl
	ld d, (hl)
	;de = fsDriver

	and a ;clear carry
	ld hl, 0
	adc hl, de
	jr z, error ;fsdriver null pointer
	ld (ix + driveTableFsdriver), e
	ld (ix + driveTableFsdriver + 1), d

	ld hl, fs_init
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	jp (hl)


error:
	ld a, 1 ;invalid fs type
	ret
#endlocal


#data RAM
	;; TODO align
;; SECTION ram_driveTable
driveTable:
	defs driveTableEntries * driveTableEntrySize
driveTablePaths:
	defs driveTableEntries * driveTableEntrySize

#include "mount.asm"
#include "unmount.asm"
