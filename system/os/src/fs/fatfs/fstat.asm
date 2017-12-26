.list

.func fat_fstat:
;; Get information about a file.
;;
;; Input:
;; : ix - file entry addr
;; : (de) - stat
;;
;; Output:
;; : a - errno


	push de

	;check if root dir (filetype == dir && startCluster == 0)
	ld a, (ix + fileTableMode)
	bit M_DIR_BIT, a
	jp z, notRootDir

	ld l, (ix + fat_fileTableStartCluster)
	ld h, (ix + fat_fileTableStartCluster + 1)
	ld de, 0
	or a
	sbc hl, de
	jr z, rootDir
notRootDir:
	ld a, (ix + fileTableDriveNumber)
	ld h, 0 + (driveTable >> 8)
	ld l, a
	;hl = drive entry

	ld bc, driveTableDevfd
	add hl, bc
	ld a, (hl) ;a = devfd

	ld d, ixh
	ld e, ixl
	ld hl, fat_fileTableDirEntryAddr
	add hl, de
	ex de, hl ;(de) = dir entry addr

	ld h, SEEK_SET
	push af
	call k_lseek
	pop af
	;TODO error handling
	
	;load the directory entry
	ld de, fat_dirEntryBuffer
	ld hl, 32
	call k_read
	;TODO error handling
	pop de
	jp fat_statFromEntry

rootDir:
	pop de
	xor a
	ld (de), a ;name = null
	ld hl, STAT_ATTRIB
	add hl, de ;(hl) = stat attrib
	;TODO permission of drive
	ld (hl), ST_DIR | SP_WRITE | SP_READ
	;a = 0
	ret

error:
	pop de
	ld a, 1
	ret
.endf

.func fat_statFromEntry:
;; Creates a stat from a directory entry.
;;
;; Input:
;; : (de) - stat
	
	ld hl, fat_dirEntryBuffer
	;(de) = stat
	push de
	call fat_buildFilename
	pop de

	ld hl, fat_dirEntryBuffer + 0x0b ;attributes
	ld b, (hl)
	ld hl, STAT_ATTRIB
	add hl, de ;(hl) = stat attrib

	ld a, SP_READ
	bit FAT_ATTRIB_RDONLY, b
	jr nz, skipWrite
	or SP_WRITE
skipWrite:
	bit FAT_ATTRIB_DIR, b
	jr nz, dir
	or ST_REG
	jr writeAttrib
dir:
	or ST_DIR
writeAttrib:
	ld (hl), a

	ld bc, STAT_SIZE - (STAT_ATTRIB)
	add hl, bc
	ex de, hl ;(de) = stat size
	ld hl, fat_dirEntryBuffer + 0x1c ;size
	call ld32
	xor a
	ret
.endf
