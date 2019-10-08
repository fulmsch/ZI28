( Editor )
variable scr

: list-line ( addr n -- ) . space 64 type cr ;
: list ( scr# -- )
    dup scr ! block
    ." Screen " scr @ . block-buffer-status @ block-clean =
    if ." not " then ." modified" cr
    16 0 do dup i list-line 64 + loop drop
;

: ls ( scr# -- ) ( list screen ) list ;
: ds ( scr# -- ) ( delete screen )
    dup scr ! block
;
: cs ( scr# -- ) ( change screen ) ;
: ll ( line# -- ) ( list line )
    dup 64 * scr @ block + swap cr list-line ;
: dl ( line# -- ) ( delete line )
    64 * scr @ block +
    64 0 do dup 32 swap c! 1+ loop drop
    block-dirty block-buffer-status !
;
: cl ( line# -- ) ( change line )
    dup dl
    dup cr . space ." * "
    64 * scr @ block +
    64 0 do
        key dup 10 = if 2drop unloop exit then
        2dup emit c! 1+
    loop drop
;
