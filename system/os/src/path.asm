#code ROM

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

#local
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

return:
	ld hl, realpath_output
	push hl
	call strtup
	pop hl
	ret
#endlocal


#data RAM

realpath_outputProt: defs 1
realpath_output:     defs PATH_MAX


#code ROM

get_drive_and_path:
;; Get the drive number and relative path from an absolute path.
;;
;; Input:
;; : (hl) - absolute path
;;
;; Output:
;; : (hl) - relative path to fs root
;; : (de) - drive entry
;; : carry - error

#local
	ld a, (hl)
	cp '/'
	scf
	ret nz ;path must begin with '/'

	ld de, driveTable
	ld b, 0xff ;parent

traverseTree:
	ld a, (hl)
	cp 0
	jr z, parentEnd
	push de ;drive entry
	push hl ;path
	inc d ;mount table
	call strbegins ;does the path begin with the current mount point?
	jr z, nextChild
	ld a, (hl)
	cp 0
	jr nz, nextSibling
	pop de ;path
	pop hl ;drive entry
	push hl
	push de
	inc h ;mount table
	call strbegins ;does the current mount point begin with the path?
	jr nz, nextSibling
	ld a, (hl)
	cp '/'
	jr nz, nextSibling
	inc hl
	ld a, (hl)
	cp 0x00
	jr nz, nextSibling
	ex de, hl

nextChild:
	pop de ;old path, discard
	pop de ;drive entry

	ld a, (de) ;child
	cp 0xff
	jr z, end
	ld b, e ;save e as parent
	ld e, a
	jr traverseTree


nextSibling:
	pop hl ;path
	pop de ;drive entry

	inc de ;point to sibling
	ld a, (de)
	cp 0xff
	jr z, parentEnd
	ld e, a ;sibling
	jr traverseTree

parentEnd:
	ld e, b
end:
	;error if e == 0xff
	inc e
	ret c
	dec e
	ret
#endlocal


#code ROM

u_getcwd:
k_getcwd:
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


#code ROM

u_chdir:
k_chdir:
;; Change the current working directory
;;
;; Input:
;; : (hl) - path
;;
;; Output:
;; : a - errno

#local
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
	;de points to dest null terminator
	dec de
	ld a, (de)
	cp '/'
	jr z, removeSlash
	xor a
	ret

removeSlash:
	xor a
	ld hl, env_workingPath
	sbc hl, de
	ret z
	ld (de), a
	ret

error:
	pop hl
	ld a, 1
	ret
#endlocal
