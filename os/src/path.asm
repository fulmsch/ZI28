;;
.list
.z80

.func realpath:
;; Convert any path (relative or absolute) to a complete path.
;;
;; Input:
;; : (hl) - path
;;
;; Output:
;; : (hl) - complete path

; Rules:
; Multiple slashes -> single slash
; Remove './'
; '../' -> remove previous directory, unless that is the root
; First char | Path type
; --------------------------------------------------
;  '/'       | Absolute (on current drive)
;  ':/'      | Absolute (on main drive)
;  ':'       | Full (incl. drive)
;  else      | Relative to current working directory

	ld de, realpath_output

	;check if absolute
	ld a, (hl)
	cp '/'
	jp z, absCurrentDrive
	cp ':'
	jr nz, relative
	inc hl
	ld a, (hl)
	cp '/'
	jp z, absMainDrive

	dec hl

	;Full path
	;move to first '/'
fullLoop:
	ld a, (hl)
	ld (de), a
	cp 0x00
	jp z, return
	cp '/'
	jr z, cleanUpPath
	inc hl
	inc de
	jr fullLoop

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

	dec hl ;in case of a jump to regloop
	cp 0x00
	jr z, regLoop ;terminate the string and return
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
	cp ':'
	jr z, rootdir
	cp '/'
	jr nz, backtrackLoop

	inc de ;de points to first char after '/'
	jr slashLoop

rootdir:
	;de points to ':'
rootdirLoop:
	inc de
	ld a, (de)
	cp '/'
	jr nz, rootdirLoop
	inc de
	jr slashLoop


relative:
	;copy working directory, append path, clean up
	push hl
	ld hl, env_workingPath
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


absCurrentDrive:
	;copy current drive, append path, clean up
	push hl
	ld hl, env_workingPath - 1
	dec de
currentDriveLoop:
	inc hl
	inc de
	ld a, (hl)
	ld (de), a
	cp 0x00
	jr z, currentDriveLoopExit
	cp '/'
	jr nz, currentDriveLoop
currentDriveLoopExit:

	pop hl
	;de points to '/' or 0, gets overwritten with '/' of absolute path
	jr cleanUpPath


absMainDrive:
	;copy main drive, append path, clean up
	push hl
	ld hl, env_mainDrive
	call strcpy
	dec de ;de now points to '/'
	pop hl
	jp cleanUpPath


return:
	ld hl, realpath_output
	push hl
	call strtup
	pop hl
	ret
.endf


u_getcwd:
.func k_getcwd:
;; Return the current working directory
;;
;; Input:
;; : (hl) - buffer
;;
;; Output:
;; : a - errno

	ex de, hl
	ld hl, env_workingPath
	call strcpy
	xor a
	ret
.endf


u_chdir:
.func k_chdir:
;; Change the current working directory
;;
;; Input:
;; : (hl) - path
;;
;; Output:
;; : a - errno

	push hl

	ex de, hl
	ld a, O_RDONLY | O_DIRECTORY
	call k_open
	cp 0
	jr nz, error

	ld a, e
	call k_close

	pop hl
	call realpath
	ld de, env_workingPath
	call strcpy
	xor a
	ret

error:
	pop hl
	ld a, 1
	ret
.endf
