# $Id: Modules.mk,v 1.23 2005/06/05 02:57:49 ikerekes Exp $

# these are base modules to be used for the fs types, IDE and
# their dependancies
DEF_MODULES_PATH_24=\
	fs/ext3/ext3 \
	fs/jbd/jbd \
	fs/nls/nls_iso8859-13 \
	fs/nls/nls_iso8859-14 \
	fs/nls/nls_iso8859-15 \
	fs/nls/nls_iso8859-1 \
	fs/nls/nls_iso8859-2 \
	fs/nls/nls_iso8859-3 \
	fs/nls/nls_iso8859-4 \
	fs/nls/nls_iso8859-5 \
	fs/nls/nls_iso8859-6 \
	fs/nls/nls_iso8859-7 \
	fs/nls/nls_iso8859-8 \
	fs/nls/nls_iso8859-9 \
	fs/nls/nls_utf8

# modules not loaded/needed:
#	fs/ext3/ext3
#	fs/jbd/jbd
DEF_MODULES_PATH_26=\
	fs/nls/nls_iso8859-13 \
	fs/nls/nls_iso8859-14 \
	fs/nls/nls_iso8859-15 \
	fs/nls/nls_iso8859-1 \
	fs/nls/nls_iso8859-2 \
	fs/nls/nls_iso8859-3 \
	fs/nls/nls_iso8859-4 \
	fs/nls/nls_iso8859-5 \
	fs/nls/nls_iso8859-6 \
	fs/nls/nls_iso8859-7 \
	fs/nls/nls_iso8859-9 \
	fs/nls/nls_utf8

# these are the dependancies for the above
DEF_MODULES_OPT_PATH_24=\
	lib/zlib_inflate/zlib_inflate

DEF_MODULES_OPT_PATH_26=\
	lib/zlib_inflate/zlib_inflate

DEF_MODULES_DEP_PATH_24=\
	fs/isofs/isofs \
	drivers/cdrom/cdrom \
	drivers/ide/ide-cd \
	drivers/misc/aes \
	drivers/block/loop

DEF_MODULES_DEP_PATH_26=\
	fs/isofs/isofs \
	drivers/cdrom/cdrom \
	drivers/ide/ide-cd \
	drivers/block/loop 

# these modules are for all the SCSI types out there
# not available: ncr53c8xx
# removed: drivers/scsi/aic7xxx_old (two modules seems to hang Adaptec controllers)
DEF_SCSI_MODULES_PATH_24=\
	drivers/scsi/aic7xxx/aic7xxx \
	drivers/scsi/BusLogic \
	drivers/scsi/initio \
	drivers/scsi/advansys \
	drivers/scsi/aha1542 \
	drivers/scsi/aha152x \
	drivers/scsi/aha1740 \
	drivers/scsi/atp870u \
	drivers/scsi/dtc \
	drivers/scsi/eata \
	drivers/scsi/fdomain \
	drivers/scsi/gdth \
	drivers/scsi/megaraid \
	drivers/scsi/NCR53c406a \
	drivers/scsi/pas16 \
	drivers/scsi/pci2220i \
	drivers/scsi/pci2000 \
	drivers/scsi/psi240i \
	drivers/scsi/qlogicfas \
	drivers/scsi/qlogicfc \
	drivers/scsi/qlogicisp \
	drivers/scsi/seagate \
	drivers/scsi/t128 \
	drivers/scsi/tmscsim \
	drivers/scsi/u14-34f \
	drivers/scsi/ultrastor \
	drivers/scsi/wd7000 \
	drivers/scsi/a100u2w \
	drivers/scsi/3w-xxxx \
	drivers/message/fusion/mptscsih

# insmod module segfaults (no chip): 
#	drivers/scsi/a100u2w
#	drivers/scsi/dc395x
#	drivers/scsi/megaraid
#	drivers/scsi/nsp32
#	drivers/scsi/qla1280
#	drivers/scsi/sym53c8xx_2/sym53c8xx
#	drivers/scsi/atp870u
# insmod hangs (no chip):
#	drivers/scsi/ips
# insmod loads wrongly (no chip):
#	drivers/scsi/53c700
#	drivers/scsi/aacraid/aacraid
#	drivers/scsi/aha152x
#	drivers/scsi/aha1740
DEF_SCSI_MODULES_PATH_26=\
	drivers/scsi/3w-xxxx \
#	drivers/scsi/advansys \
	drivers/scsi/aha1542 \
	drivers/scsi/aic7xxx/aic7xxx \
	drivers/scsi/BusLogic \
#	drivers/scsi/cpqfc \
	drivers/scsi/dmx3191d \
	drivers/scsi/dtc \
	drivers/scsi/eata \
	drivers/scsi/fdomain \
	drivers/scsi/gdth \
	drivers/scsi/g_NCR5380 \
	drivers/scsi/in2000 \
	drivers/scsi/NCR53c406a \
	drivers/scsi/pas16 \
	drivers/scsi/psi240i \
	drivers/scsi/qlogicfas \
	drivers/scsi/qlogicfc \
	drivers/scsi/qlogicisp \
	drivers/scsi/sym53c416 \
	drivers/scsi/t128 \
	drivers/scsi/tmscsim \
	drivers/scsi/u14-34f \
	drivers/scsi/ultrastor \
	drivers/scsi/wd7000 \
	drivers/message/fusion/mptscsih

# depending on kernel version, these have different names
DEF_SCSI_MODULES_OPT_PATH_24=\
	drivers/scsi/sym53c8xx_2/sym53c8xx \
	drivers/scsi/sym53c8xx_2/sym53c8xx_2

# this one is just here to ensure we work (already included)
DEF_SCSI_MODULES_OPT_PATH_26=\
	drivers/scsi/3w-xxxx

# these are dependancies for the above modules
DEF_SCSI_MODULES_DEP_PATH_24=\
	drivers/scsi/scsi_mod \
	drivers/scsi/sr_mod \
	drivers/scsi/sd_mod \
	drivers/message/fusion/mptbase

DEF_SCSI_MODULES_DEP_PATH_26=\
	drivers/scsi/scsi_mod \
	drivers/scsi/sr_mod \
	drivers/scsi/sd_mod \
	drivers/message/fusion/mptbase

DEF_USB_MODULES_PATH_24=\
	drivers/usb/usbcore

DEF_USB_MODULES_DRV_PATH_24=\
	drivers/usb/host/uhci \
	drivers/usb/storage/usb-storage

DEF_USB_MODULES_PATH_26=\
	drivers/usb/core/usbcore

DEF_USB_MODULES_DRV_PATH_26=\
	drivers/usb/host/uhci-hcd \
	drivers/usb/host/ohci-hcd \
	drivers/usb/host/ehci-hcd \
	drivers/usb/storage/usb-storage

# convert our module paths to their basenames
DEF_MODULES_24=$(shell for m in $(DEF_MODULES_PATH_24); do basename $$m; done)
DEF_MODULES_DEP_24=$(shell for m in $(DEF_MODULES_DEP_PATH_24); do basename $$m; done)
DEF_MODULES_OPT_24=$(shell for m in $(DEF_MODULES_OPT_PATH_24); do basename $$m; done)
DEF_SCSI_MODULES_24=$(shell for m in $(DEF_SCSI_MODULES_PATH_24); do basename $$m; done)
DEF_SCSI_MODULES_OPT_24=$(shell for m in $(DEF_SCSI_MODULES_OPT_PATH_24); do basename $$m; done)
DEF_SCSI_MODULES_DEP_24=$(shell for m in $(DEF_SCSI_MODULES_DEP_PATH_24); do basename $$m; done)
DEF_USB_MODULES_24=$(shell for m in $(DEF_USB_MODULES_PATH_24); do basename $$m; done)
DEF_USB_MODULES_DRV_24=$(shell for m in $(DEF_USB_MODULES_DRV_PATH_24); do basename $$m; done)

DEF_MODULES_26=$(shell for m in $(DEF_MODULES_PATH_26); do basename $$m; done)
DEF_MODULES_DEP_26=$(shell for m in $(DEF_MODULES_DEP_PATH_26); do basename $$m; done)
DEF_MODULES_OPT_26=$(shell for m in $(DEF_MODULES_OPT_PATH_26); do basename $$m; done)
DEF_SCSI_MODULES_26=$(shell for m in $(DEF_SCSI_MODULES_PATH_26); do basename $$m; done)
DEF_SCSI_MODULES_OPT_26=$(shell for m in $(DEF_SCSI_MODULES_OPT_PATH_26); do basename $$m; done)
DEF_SCSI_MODULES_DEP_26=$(shell for m in $(DEF_SCSI_MODULES_DEP_PATH_26); do basename $$m; done)
DEF_USB_MODULES_26=$(shell for m in $(DEF_USB_MODULES_PATH_26); do basename $$m; done)
DEF_USB_MODULES_DRV_26=$(shell for m in $(DEF_USB_MODULES_DRV_PATH_26); do basename $$m; done)
