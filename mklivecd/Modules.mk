# $Id: Modules.mk,v 1.4 2003/12/19 12:53:30 jaco Exp $

# these are base modules to be used for the fs types, IDE and
# their dependancies
DEF_MODULES_PATH=\
	fs/ext3/ext3.o \
	fs/jbd/jbd.o \
	fs/nls/nls_iso8859-13.o \
	fs/nls/nls_iso8859-14.o \
	fs/nls/nls_iso8859-15.o \
	fs/nls/nls_iso8859-1.o \
	fs/nls/nls_iso8859-2.o \
	fs/nls/nls_iso8859-3.o \
	fs/nls/nls_iso8859-4.o \
	fs/nls/nls_iso8859-5.o \
	fs/nls/nls_iso8859-6.o \
	fs/nls/nls_iso8859-7.o \
	fs/nls/nls_iso8859-8.o \
	fs/nls/nls_iso8859-9.o \
	fs/nls/nls_utf8.o

# these are the dependancies for the above
DEF_MODULES_OPT_PATH=\
	lib/zlib_inflate/zlib_inflate.o

DEF_MODULES_DEP_PATH= \
	fs/isofs/isofs.o \
	drivers/cdrom/cdrom.o \
	drivers/ide/ide-cd.o \
	drivers/misc/aes.o \
	drivers/block/loop.o

# these modules are for all the SCSI types out there
# not available: ncr53c8xx
# removed: drivers/scsi/aic7xxx_old.o (two modules seems to hang Adaptec controllers)
DEF_SCSI_MODULES_PATH= \
	drivers/scsi/aic7xxx/aic7xxx.o \
	drivers/scsi/BusLogic.o \
	drivers/scsi/NCR53c406a.o \
	drivers/scsi/initio.o \
	drivers/scsi/advansys.o \
	drivers/scsi/aha1740.o \
	drivers/scsi/aha1542.o \
	drivers/scsi/aha152x.o \
	drivers/scsi/atp870u.o \
	drivers/scsi/dtc.o \
	drivers/scsi/eata.o \
	drivers/scsi/fdomain.o \
	drivers/scsi/gdth.o \
	drivers/scsi/megaraid.o \
	drivers/scsi/pas16.o \
	drivers/scsi/pci2220i.o \
	drivers/scsi/pci2000.o \
	drivers/scsi/psi240i.o \
	drivers/scsi/qlogicfas.o \
	drivers/scsi/qlogicfc.o \
	drivers/scsi/qlogicisp.o \
	drivers/scsi/seagate.o \
	drivers/scsi/t128.o \
	drivers/scsi/tmscsim.o \
	drivers/scsi/u14-34f.o \
	drivers/scsi/ultrastor.o \
	drivers/scsi/wd7000.o \
	drivers/scsi/a100u2w.o \
	drivers/scsi/3w-xxxx.o

# depending on kernel version, these have different names
DEF_SCSI_MODULES_OPT_PATH= \
	drivers/scsi/sym53c8xx_2/sym53c8xx.o \
	drivers/scsi/sym53c8xx_2/sym53c8xx_2.o

# these are dependancies for the above modules
DEF_SCSI_MODULES_DEP_PATH=\
	drivers/scsi/scsi_mod.o \
	drivers/scsi/sr_mod.o \
	drivers/scsi/sd_mod.o

# convert our module paths to their basenames
DEF_MODULES=$(shell for m in $(DEF_MODULES_PATH); do basename $$m; done)
DEF_MODULES_DEP=$(shell for m in $(DEF_MODULES_DEP_PATH); do basename $$m; done)
DEF_MODULES_OPT=$(shell for m in $(DEF_MODULES_OPT_PATH); do basename $$m; done)
DEF_SCSI_MODULES=$(shell for m in $(DEF_SCSI_MODULES_PATH); do basename $$m; done)
DEF_SCSI_MODULES_OPT=$(shell for m in $(DEF_SCSI_MODULES_OPT_PATH); do basename $$m; done)
DEF_SCSI_MODULES_DEP=$(shell for m in $(DEF_SCSI_MODULES_DEP_PATH); do basename $$m; done)
