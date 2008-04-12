# $Id: Modules.mk,v 1.35 2008/04/12 09:31:05 ikerekes Exp $

# these are base modules to be used for the fs types, IDE and
# their dependancies

DEF_MODULES_26=\
	nls_iso8859-1 \
	nls_iso8859-2 \
	nls_cp437 \
	jbd \
        ext3 \
        reiserfs \
        fat \
        msdos \
	vfat \
        ntfs \
	nls_utf8

# these are the dependancies for the above

DEF_MODULES_OPT_26=\
	zlib_deflate

DEF_MODULES_DEP_26=\
	isofs \
	cdrom \
	ide-cd \
	squashfs \
	loop \
	paride \
	parport 
#	drivers/block/paride/pcd \
#	sqlzma \
#	unlzma \

# these modules are for all the SCSI types out there
# not available: ncr53c8xx
# removed: drivers/scsi/aic7xxx_old (two modules seems to hang Adaptec controllers)
DEF_SCSI_MODULES_26=\
	ahci \
	ata_generic \
	ata_piix \
	pata_ali \
	pata_amd \
	pata_artop \
	pata_atiixp \
	pata_cmd640 \
	pata_cmd64x \
	pata_cs5520 \
	pata_cs5530 \
	pata_cs5535 \
	pata_cypress \
	pata_efar \
	pata_hpt366 \
	pata_hpt37x \
	pata_hpt3x2n \
	pata_hpt3x3 \
	pata_isapnp \
	pata_it8213 \
	pata_it821x \
	pata_jmicron \
	pata_legacy \
	pata_marvell \
	pata_mpiix \
	pata_netcell \
	pata_ns87410 \
	pata_oldpiix \
	pata_optidma \
	pata_opti \
	pata_pcmcia \
	pata_pdc2027x \
	pata_pdc202xx_old \
	pata_platform \
	pata_qdi \
	pata_radisys \
	pata_rz1000 \
	pata_sc1200 \
	pata_serverworks \
	pata_sil680 \
	pata_sis \
	pata_sl82c105 \
	pata_triflex \
	pata_via \
	pata_winbond \
	pdc_adma \
	sata_inic162x \
	sata_mv \
	sata_nv \
	sata_promise \
	sata_qstor \
	sata_sil24 \
	sata_sil \
	sata_sis \
	sata_svw \
	sata_sx4 \
	sata_uli \
	sata_via \
	sata_vsc \
	3w-9xxx \
	3w-xxxx \
	a100u2w \
	aacraid \
	advansys \
	aha152x \
	aha1542 \
	aic79xx \
	aic7xxx \
	aic7xxx_old \
	aic94xx \
	arcmsr \
	atp870u \
	BusLogic \
	ch \
	dc395x \
	dmx3191d \
	dpt_i2o \
	dtc \
	eata \
	fdomain \
	gdth \
	g_NCR5380 \
	g_NCR5380_mmio \
	hptiop \
	ide-scsi \
	imm \
	in2000 \
	initio \
	ipr \
	ips \
	lpfc \
	megaraid \
	megaraid_mbox \
	megaraid_sas \
	NCR53c406a \
	nsp32 \
	osst \
	pas16 \
	ppa \
	psi240i \
	qla1280 \
	qla2xxx \
	qla4xxx \
	qlogicfas \
	raid_class \
	seagate \
	stex \
	st \
	sym53c416 \
	sym53c8xx \
	tmscsim \
	u14-34f \
	ultrastor \
	wd7000 \
	sx8 


# this one is just here to ensure we work (already included)
DEF_SCSI_MODULES_OPT_26=\
	3w-xxxx

# these are dependancies for the above modules
DEF_SCSI_MODULES_DEP_26=\
	scsi_mod \
	sr_mod \
	libata \
	sg \
	sd_mod \
	scsi_transport_fc \
	scsi_transport_sas \
	scsi_transport_spi \
	mptbase \
	mptscsih \
	i2o_core \
	megaraid_mm \
	qlogicfas408
	
DEF_USB_MODULES_26=\
	usbcore

DEF_USB_MODULES_DRV_26=\
	uhci-hcd \
	ohci-hcd \
	ehci-hcd \
	usb-storage
