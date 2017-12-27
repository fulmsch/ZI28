.list

.define errorTableSize errorTableEnd - errorTable

.func _strerror:
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
.endf

invalidErrno_msg:
	.asciiz "Unknown error."

errorTable:
	.dw ENOERR_msg
	.dw EPERM_msg
	.dw ENOENT_msg
	.dw EINTR_msg
	.dw EIO_msg
	.dw ENXIO_msg
	.dw EBADF_msg
	.dw ENOMEM_msg
	.dw EACCES_msg
	.dw EFAULT_msg
	.dw ENOTBLK_msg
	.dw EBUSY_msg
	.dw EEXIST_msg
	.dw ENODEV_msg
	.dw ENOTDIR_msg
	.dw EISDIR_msg
	.dw EINVAL_msg
	.dw EMFILE_msg
	.dw ENFILE_msg
	.dw ENOTTY_msg
	.dw EFBIG_msg
	.dw ENOSPC_msg
	.dw ESPIPE_msg
	.dw EROFS_msg
	.dw EDOM_msg
	.dw ERANGE_msg
	.dw EAGAIN_msg
	.dw EWOULDBLOCK_msg
	.dw EINPROGRESS_msg
	.dw EALREADY_msg
	.dw ENAMETOOLONG_msg
	.dw ENOTEMPTY_msg
	.dw EFTYPE_msg
	.dw ENOSYS_msg
	.dw ENOTSUP_msg
	.dw ENOMSG_msg
	.dw EOVERFLOW_msg
	.dw ETIME_msg
	.dw ECANCELED_msg
	.dw EBADFD_msg
errorTableEnd:

ENOERR_msg:
	.asciiz ""

EPERM_msg:
	.asciiz "Operation not permitted."

ENOENT_msg:
	.asciiz "No such file or directory."

EINTR_msg:
	.asciiz "Interrupted system call."

EIO_msg:
	.asciiz "Input/output error."

ENXIO_msg:
	.asciiz "No such device or address."

EBADF_msg:
	.asciiz "Bad file descriptor."

ENOMEM_msg:
	.asciiz "Cannot allocate memory."

EACCES_msg:
	.asciiz "Permission denied."

EFAULT_msg:
	.asciiz "Bad address."

ENOTBLK_msg:
	.asciiz "Block device required."

EBUSY_msg:
	.asciiz "Device or resource busy."

EEXIST_msg:
	.asciiz "File exists."

ENODEV_msg:
	.asciiz "No such device."

ENOTDIR_msg:
	.asciiz "Not a directory."

EISDIR_msg:
	.asciiz "Is a directory."

EINVAL_msg:
	.asciiz "Invalid argument."

EMFILE_msg:
	.asciiz "Too many open files."

ENFILE_msg:
	.asciiz "Too many open files in system."

ENOTTY_msg:
	.asciiz "Inappropriate ioctl for device."

EFBIG_msg:
	.asciiz "File too large."

ENOSPC_msg:
	.asciiz "No space left on device."

ESPIPE_msg:
	.asciiz "Illegal seek."

EROFS_msg:
	.asciiz "Read-only file system."

EDOM_msg:
	.asciiz "Numerical argument out of domain."

ERANGE_msg:
	.asciiz "Numerical result out of range."

EAGAIN_msg:
	.asciiz "Resource temporarily unavailable."

EWOULDBLOCK_msg:
	.asciiz "Operation would block."

EINPROGRESS_msg:
	.asciiz "Operation now in progress."

EALREADY_msg:
	.asciiz "Operation already in progress."

ENAMETOOLONG_msg:
	.asciiz "File name too long."

ENOTEMPTY_msg:
	.asciiz "Directory not empty."

EFTYPE_msg:
	.asciiz "Inappropriate file type or format."

ENOSYS_msg:
	.asciiz "Function not implemented."

ENOTSUP_msg:
	.asciiz "Not supported."

ENOMSG_msg:
	.asciiz "No message of desired type."

EOVERFLOW_msg:
	.asciiz "Value too large for defined data type."

ETIME_msg:
	.asciiz "Timer expired."

ECANCELED_msg:
	.asciiz "Operation canceled."

EBADFD_msg:
	.asciiz "File descriptor in bad state."
