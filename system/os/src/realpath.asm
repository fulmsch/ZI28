SECTION rom_code
INCLUDE "os.h"
INCLUDE "string.h"
INCLUDE "process.h"

PUBLIC realpath

realpath:
;; Convert any path to an absolute path.
;;
;; Input:
;; : (hl) - path
;;
;; Output:
;; : (hl) - absolute path

; Rules:
; Multiple slashes -> single slash
; Remove './'
; '../' -> remove previous directory, unless that is the root

	ld de, realpath_outputProt
	xor a
	ld (de), a
	inc de

	;check if absolute
	ld a, (hl)
	cp '/'
	jr nz, relative

cleanUpPath:
	;(hl) = read
	;(de) = write

regLoop:
	;copy everything including first '/'
	ld a, (hl)
	ld (de), a
	cp 0x00
	jp z, return
	inc de
	inc hl
	cp '/'
	jr nz, regLoop

	;hl points to first '/'
	;skip to first char that's not a '/'
slashLoop:
	ld a, (hl)
	inc hl
	cp '/'
	jr z, slashLoop

	;hl points to second char after '/'
	;a = first char after a group of '/'
	cp '.'
	dec hl
	jr nz, regLoop ;continue copying

relDotEntry:
	inc hl

	;hl points to first char after first dot
	ld a, (hl)
	cp '/'
	jr z, slashLoop ;a '/' has already been copied, ignore any further '/'

	cp 0x00
	jr z, regLoop ;terminate the string and return
	dec hl ;in case of a jump to regloop
	cp '.'
	jr nz, regLoop ;regular filename starting with a dot
	inc hl

	inc hl
	ld a, (hl)
	cp 0x00
	jr z, backtrack
	cp '/' ;is there a '/' after '..'?
	dec hl
	dec hl
	jr nz, regLoop ;regular filename starting with two dots
	inc hl
	inc hl

backtrack:
	;hl points to '/' after '..'
	;move de back to the first char after the last '/' if we're not already in
	;the root dir

	dec de
	;de now points to a '/'
backtrackLoop:
	dec de
	ld a, (de)
	cp 0x00
	jr z, rootdir
	cp '/'
	jr nz, backtrackLoop

	inc de ;de points to first char after '/'
	jr slashLoop

rootdir:
	;de points to 0x00
	inc de ;to first '/'
	inc de ;to first char of path
	jr slashLoop


relative:
	;copy working directory, append path, clean up
	push hl
	ld hl, process_workingDir
	call strcpy
	pop hl

	;de points to null terminator after working dir
	dec de
	ld a, (de)
	inc de
	cp '/'
	jr z, relSkipSlash

	ld a, '/'
	ld (de), a
	inc de

relSkipSlash:
	ld a, (hl)
	cp '.'
	jr nz, cleanUpPath
	jr relDotEntry

return:
	ld hl, realpath_output
	push hl
	call strtup
	pop hl
	ret


SECTION ram_os

realpath_outputProt: defs 1
realpath_output:     defs PATH_MAX
