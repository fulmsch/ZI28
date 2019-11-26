#code ROM

_strerror:
;; Return a string describing an error number.
;;
;; Input:
;; : a - error number
;;
;; Output:
;; : (hl) - error message
;;
;; Destroyed:
;; : None

#local
	ld hl, invalidErrno_msg
	cp 0 + (errorTableSize) / 2
	ret nc
	add a, a
	ld h, 0
	ld l, a
	srl a ;restore a
	push de
	ld de, errorTable
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	pop de
	ret


invalidErrno_msg:
	DEFM "Unknown error.", 0x00

#define errorTableSize errorTableEnd - errorTable
errorTable:
	DEFW ENOERR_msg
	DEFW EPERM_msg
	DEFW ENOENT_msg
	DEFW EINTR_msg
	DEFW EIO_msg
	DEFW ENXIO_msg
	DEFW EBADF_msg
	DEFW ENOMEM_msg
	DEFW EACCES_msg
	DEFW EFAULT_msg
	DEFW ENOTBLK_msg
	DEFW EBUSY_msg
	DEFW EEXIST_msg
	DEFW ENODEV_msg
	DEFW ENOTDIR_msg
	DEFW EISDIR_msg
	DEFW EINVAL_msg
	DEFW EMFILE_msg
	DEFW ENFILE_msg
	DEFW ENOTTY_msg
	DEFW EFBIG_msg
	DEFW ENOSPC_msg
	DEFW ESPIPE_msg
	DEFW EROFS_msg
	DEFW EDOM_msg
	DEFW ERANGE_msg
	DEFW EAGAIN_msg
	DEFW EWOULDBLOCK_msg
	DEFW EINPROGRESS_msg
	DEFW EALREADY_msg
	DEFW ENAMETOOLONG_msg
	DEFW ENOTEMPTY_msg
	DEFW EFTYPE_msg
	DEFW ENOSYS_msg
	DEFW ENOTSUP_msg
	DEFW ENOMSG_msg
	DEFW EOVERFLOW_msg
	DEFW ETIME_msg
	DEFW ECANCELED_msg
	DEFW EBADFD_msg
	DEFW EPROCLIM_msg
	DEFW E2BIG_msg
errorTableEnd:
	DEFB 0

;SECTION rom_data

ENOERR_msg:
	DEFM 0x00

EPERM_msg:
	DEFM "Operation not permitted.", 0x00

ENOENT_msg:
	DEFM "No such file or directory.", 0x00

EINTR_msg:
	DEFM "Interrupted system call.", 0x00

EIO_msg:
	DEFM "Input/output error.", 0x00

ENXIO_msg:
	DEFM "No such device or address.", 0x00

EBADF_msg:
	DEFM "Bad file descriptor.", 0x00

ENOMEM_msg:
	DEFM "Cannot allocate memory.", 0x00

EACCES_msg:
	DEFM "Permission denied.", 0x00

EFAULT_msg:
	DEFM "Bad address.", 0x00

ENOTBLK_msg:
	DEFM "Block device required.", 0x00

EBUSY_msg:
	DEFM "Device or resource busy.", 0x00

EEXIST_msg:
	DEFM "File exists.", 0x00

ENODEV_msg:
	DEFM "No such device.", 0x00

ENOTDIR_msg:
	DEFM "Not a directory.", 0x00

EISDIR_msg:
	DEFM "Is a directory.", 0x00

EINVAL_msg:
	DEFM "Invalid argument.", 0x00

EMFILE_msg:
	DEFM "Too many open files.", 0x00

ENFILE_msg:
	DEFM "Too many open files in system.", 0x00

ENOTTY_msg:
	DEFM "Inappropriate ioctl for device.", 0x00

EFBIG_msg:
	DEFM "File too large.", 0x00

ENOSPC_msg:
	DEFM "No space left on device.", 0x00

ESPIPE_msg:
	DEFM "Illegal seek.", 0x00

EROFS_msg:
	DEFM "Read-only file system.", 0x00

EDOM_msg:
	DEFM "Numerical argument out of domain.", 0x00

ERANGE_msg:
	DEFM "Numerical result out of range.", 0x00

EAGAIN_msg:
	DEFM "Resource temporarily unavailable.", 0x00

EWOULDBLOCK_msg:
	DEFM "Operation would block.", 0x00

EINPROGRESS_msg:
	DEFM "Operation now in progress.", 0x00

EALREADY_msg:
	DEFM "Operation already in progress.", 0x00

ENAMETOOLONG_msg:
	DEFM "File name too long.", 0x00

ENOTEMPTY_msg:
	DEFM "Directory not empty.", 0x00

EFTYPE_msg:
	DEFM "Inappropriate file type or format.", 0x00

ENOSYS_msg:
	DEFM "Function not implemented.", 0x00

ENOTSUP_msg:
	DEFM "Not supported.", 0x00

ENOMSG_msg:
	DEFM "No message of desired type.", 0x00

EOVERFLOW_msg:
	DEFM "Value too large for defined data type.", 0x00

ETIME_msg:
	DEFM "Timer expired.", 0x00

ECANCELED_msg:
	DEFM "Operation canceled.", 0x00

EBADFD_msg:
	DEFM "File descriptor in bad state.", 0x00

EPROCLIM_msg:
	DEFM "Too many processes.", 0x00

E2BIG_msg:
	DEFM "Argument list too long.", 0x00
#endlocal
