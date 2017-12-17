ROOTDIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
UTILDIR = $(ROOTDIR)/tools
INCLUDEDIR = $(ROOTDIR)/include
SYSROOT = $(ROOTDIR)/user/sysroot
MFLAGS = -j -l2 --no-print-directory
