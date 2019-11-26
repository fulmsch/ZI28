; FAT-16 file system

;drive table
#define fat_fat1StartAddr     driveTableFsData          ;4 bytes
#define fat_fat2StartAddr     fat_fat1StartAddr + 4     ;4 bytes
#define fat_rootDirStartAddr  fat_fat2StartAddr + 4     ;4 bytes
#define fat_dataStartAddr     fat_rootDirStartAddr + 4  ;4 bytes
#define fat_sectorsPerCluster fat_dataStartAddr + 4     ;1 byte
#define fat_firstFreeCluster  fat_sectorsPerCluster + 2 ;2 bytes
                                                 ;Total 19 bytes


#define fat_fileTableStartCluster fileTableData                 ;2 bytes
#define fat_fileTableDirEntryAddr fat_fileTableStartCluster + 2 ;4 bytes


;file attributes
#define FAT_ATTRIB_RDONLY  0
#define FAT_ATTRIB_HIDDEN  1
#define FAT_ATTRIB_SYSTEM  2
#define FAT_ATTRIB_VOLLBL  3
#define FAT_ATTRIB_DIR     4
#define FAT_ATTRIB_ARCHIVE 5
#define FAT_ATTRIB_DEVICE  6


;Boot sector contents              Offset|Length (in bytes)
#define FAT_VBR_OEM_NAME             0x03 ;8
#define FAT_VBR_BYTES_PER_SECTOR     0x0b ;2
#define FAT_VBR_SECTORS_PER_CLUSTER  0x0d ;1
#define FAT_VBR_RESERVED_SECTORS     0x0e ;2
#define FAT_VBR_FAT_COPIES           0x10 ;1
#define FAT_VBR_MAX_ROOT_DIR_ENTRIES 0x11 ;2
#define FAT_VBR_SECTORS_SHORT        0x13 ;2
#define FAT_VBR_MEDIA_DESCRIPTOR     0x15 ;1
#define FAT_VBR_SECTORS_PER_FAT      0x16 ;2
#define FAT_VBR_SECTORS_PER_TRACK    0x18 ;2
#define FAT_VBR_HEADS                0x1a ;4
#define FAT_VBR_SECTORS_BEFORE_VBR   0x1c ;4
#define FAT_VBR_SECTORS_LONG         0x20 ;1
#define FAT_VBR_DRIVE_NUMBER         0x24 ;1
#define FAT_VBR_BOOT_RECORD_SIG      0x26 ;1
#define FAT_VBR_SERIAL_NUMBER        0x27 ;4


fat_fsDriver:
	DEFW fat_init
	DEFW fat_open
	DEFW 0x000 ;fat_close
	DEFW fat_readdir
	DEFW fat_fstat
	DEFW fat_unlink


fat_fileDriver:
	DEFW fat_read
	DEFW fat_write


fat_findFreeCluster:
;; Find the first free cluster of the first FAT.
;;
;; Starts searching at fat_firstFreeCluster and stores the next free cluster
;; there. TODO: wrap around when the end of the FAT is reached.
;;
;; Input:
;; : (iy) - drive entry
;;
;; Output:
;; : de - free cluster
;; : carry - error

#local
	ld e, (iy + fat_firstFreeCluster)
	ld d, (iy + fat_firstFreeCluster + 1)

loop:
	ex de, hl
	push hl
	call fat_getClusterValue
	pop de
	ret c
	inc de
	xor a
	cp h
	jr nz, loop
	cp l
	jr nz, loop

	dec de
	;de is a free cluster
	ld (iy + fat_firstFreeCluster), e
	ld (iy + fat_firstFreeCluster + 1), d
	;carry is cleared from cp
	ret
#endlocal


fat_getClusterValue:
;; Read the value of a cluster entry from the first FAT.
;;
;; Input:
;; : (iy) - drive entry
;; : hl - cluster number
;;
;; Output:
;; : hl - value
;; : carry - error

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, regA
	call ld16
	push hl

	ld d, iyh
	ld e, iyl
	ld hl, fat_fat1StartAddr
	add hl, de
	ex de, hl
	;(de) = fat1StartAddr
	pop hl
	call add32 ;clusterOffs + fat1StartAddr
	ex de, hl

	ld a, (iy + driveTableDevfd)
	push af
	ld h, SEEK_SET
	call k_lseek
	pop af

	ld de, fat_clusterValue
	ld hl, 2 ;count
	push ix
	call k_read
	pop ix
	ld hl, (fat_clusterValue)
	cp 0
	ret z
	scf
	ret


fat_setClusterValue:
;; Set the value of a cluster in both FATs.
;;
;; Input:
;; : hl - cluster
;; : de - new value
;; : (iy) - drive entry
;;
;; Output:
;; : carry - error

#local
	ld (fat_clusterValue), de

	add hl, hl ;double the cluster number to get its offset in the FAT
	ex de, hl
	ld hl, fat_clusterValueOffset1
	call ld16 ;cluster offset
	ld de, fat_clusterValueOffset2
	call ld32 ;regB = cluster offset

	ld d, iyh
	ld e, iyl
	ld hl, fat_fat1StartAddr
	add hl, de
	ex de, hl
	;(de) = fat1StartAddr
	ld hl, fat_clusterValueOffset1
	call add32 ;clusterOffs + fat1StartAddr
	ld hl, fat_fat2StartAddr - (fat_fat1StartAddr)
	add hl, de
	ex de, hl
	;(de) = fat2StartAddr
	ld hl, fat_clusterValueOffset2
	call add32 ;clusterOffs + fat2StartAddr

	ld a, (iy + driveTableDevfd)
	;write to FAT 1
	ld de, fat_clusterValueOffset1
	push af
	ld h, SEEK_SET
	call k_lseek
	pop af

	ld de, fat_clusterValue
	ld hl, 2 ;count
	push af
	push ix
	call k_write
	pop ix
	cp 0
	jr nz, error
	pop af

	;write to FAT 2
	ld de, fat_clusterValueOffset2
	push af
	ld h, SEEK_SET
	call k_lseek
	pop af

	ld de, fat_clusterValue
	ld hl, 2 ;count
	push ix
	call k_write
	pop ix
	cp 0
	ret z
	scf
	ret

error:
	pop af
	scf
	ret
#endlocal


fat_addCluster:
;; Add a cluster to both FATs.
;;
;; Input:
;; : hl - cluster or 0 for empty files
;; : (iy) - drive entry
;;
;; Output:
;; : hl - added cluster
;; : carry - error

; int addCluster(int base) {
; 	new = findFreeCluster();
; 	setCluster(new, 0xffff);
; 	if (base != 0) {
; 		//possibly seek to end of cluster chain
; 		setCluster(base, new);
; 	}
; 	base points to new, which contains 0xffff
; 	return new;
; }

#local
	push hl ;base
	call fat_findFreeCluster
	jr c, error
	ex de, hl
	;hl = first free cluster
	push hl ;new
	ld de, 0xffff
	call fat_setClusterValue
	pop hl ;new
	pop de ;base
	ret c

	xor a
	cp d
	jr nz, appendCluster
	cp e
	ret z ;carry is reset

appendCluster:
	push hl
	ex de, hl
	call fat_setClusterValue
	pop hl
	ret

error:
	pop hl
	scf
	ret
#endlocal


fat_nextCluster:
;; Find the next cluster of a chain from the first FAT
;;
;; Input:
;; : hl - current cluster
;; : (iy) - drive entry
;;
;; Output:
;; : hl - next cluster
;; : carry - the current cluster is the last of the chain

#local
	call fat_getClusterValue
	ret c

	;check if fat entry is end of chain
	xor a
	cp h
	jr z, check00
	dec a
	cp h
	jr z, checkFF
validCluster:
	or a
	ret

check00:
	ld a, 1
	cp l
	jr c, validCluster
eoc:
	scf
	ret

checkFF:
	ld a, 0xf7
	cp l
	jr c, eoc
	jr validCluster
#endlocal


fat_clearClusterChain:
;; Clear a chain starting at the specified cluster.
;;
;; Input:
;; : hl - cluster
;; : (iy) - drive entry
;;
;; Output:
;; : carry - error

#local
	push hl ;current cluster
loop:
	call fat_nextCluster
	ex (sp), hl ;stack: next cluster, hl: current cluster to be cleared
	push af

	ld de, 0x0000
	call fat_setClusterValue
	jr c, error
	pop af
	jr nc, loop ;not end of cluster chain

	pop hl
	or a ;clear carry
	ret

error:
	;carry is set
	pop hl
	pop hl
	ret
#endlocal


fat_clusterToAddr:
;; Calculate the starting address of a cluster
;;
;; Input:
;; : (hl) - 32-bit cluster number
;; : iy - drive table entry
;;
;; Output:
;; : (hl) - address

#local
	;subtract 2 from the cluster, because of how FAT works
	call dec32
	call dec32

	ld a, (iy + fat_sectorsPerCluster)

	call lshiftbyte32
loop:
	call lshift32
	srl a
	jr nc, loop

	push hl
	ld hl, fat_dataStartAddr
	ld d, iyh
	ld e, iyl
	add hl, de
	ex de, hl
	pop hl
	call add32 ;relAddr += dataStartAddr

	ret
#endlocal


fat_buildFilename:
;; Creates a 8.3 string from a directory entry
;;
;; Input:
;; : (hl) - dir entry
;; : (de) - filename buffer (max. length: 13 bytes)
;;
;; Destroyed:
;; : a, bc, de, hl

#local
	push de
	;copy the first 8 chars of the dir entry
	ld bc, 8
	ldir
	ld a, ' '
	ld (de), a

	pop de
terminateName:
	ld a, (de)
	cp ' '
	inc de
	jr nz, terminateName
	dec de

	;de now points to the char after the name, hl to the extension of the entry
	ld a, (hl)
	cp ' '
	jr z, end
	ld a, '.'
	ld (de), a
	inc de

	ld b, 3
extension:
	ld a, (hl)
	cp ' '
	jr z, end
	ld (de), a
	inc hl
	inc de
	djnz extension

end:
	ld a, 0
	ld (de), a
	ret
#endlocal


fat_build83Filename:
;; Convert a filename to the FAT 8.3 format.
;;
;; Input:
;; : (hl) - filename (must be uppercase)
;; : (de) - output buffer (length: 11 bytes)
;;
;; Output:
;; : carry - invalid filename
;; : hl - if succesful, points to char after filename (0x00 or '/')

#local
	;clear the buffer
	push de ;buffer
	push hl ;filename
	ld h, d
	ld l, e
	inc de
	ld bc, 10
	ld (hl), ' '
	ldir
	pop hl ;filename
	pop de ;buffer

	ld b, 2
	ld c, 8

loop:
	ld a, (hl)
	cp 0x00
	ret z
	cp '/'
	ret z
	cp '.'
	jr z, dot

	;check if printable
	cp 0x21
	jr c, error
	cp 0x7f
	jr nc, error

	push de
	ld de, illegalChars
checkIllegal:
	;check if character is illegal
	ld a, (de)
	inc de
	cp (hl)
	jr z, illegal
	cp 0x00
	jr nz, checkIllegal

	pop de

	xor a
	cp c
	jr z, error
	ldi ;(de) = (hl), bc--
	jr loop

	;basename or extension too long
error:
	scf
	ret

dot:
	dec b
	jr z, error ;only one dot allowed
	ld a, 8
	cp c
	jr z, error
	xor a
	cp c
	jr z, extLoopEnd
extLoop:
	inc de
	dec c
	jr nz, extLoop
extLoopEnd:
	inc hl
	ld c, 3
	jr loop

illegal:
	pop de
	scf
	ret

illegalChars:
	DEFB '|', '<', '>', '^', '+', '=', '?', '[', ']', ';', ',', '*', '\\', '"', 0x00
#endlocal


fat_statFromEntry:
;; Creates a stat from a directory entry.
;;
;; Input:
;; : (de) - stat

#local
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
#endlocal


#data RAM
fat_dirEntryBuffer:      defs 33

fat_clusterValue:        defs 2
fat_clusterValueOffset1: defs 4
fat_clusterValueOffset2: defs 4

fat_rw_remCount:         defs 2
fat_rw_totalCount:       defs 2
fat_rw_dest:             defs 2
fat_rw_cluster:          defs 2
fat_rw_clusterSize:      defs 2

#include "init.asm"
#include "fstat.asm"
#include "open.asm"
#include "read.asm"
#include "readdir.asm"
#include "unlink.asm"
#include "write.asm"
