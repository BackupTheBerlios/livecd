# $Id: Rules.mk,v 1.6 2003/10/03 06:19:06 jaco Exp $

# User parameters: These are parameters that can be changed for
# your installation
# Valid options:
#     al am am_old am_phonetic ar az
#     be ben bg bg_phonetic br bs by
#     ch_de ch_fr cz cz_qwerty
#     de de_nodeadkeys dev dk dvorak dvorak_no dvorak_se
#     ee es fi fr ge_la ge_ru gr gr_pl guj gur hr hu
#     ie il il_phonetic ir is it iu jp kan kr
#     la lao lt lt_b lt_new lt_p lv mal mk mm mng mt mt_us
#     nl no ori pl pl2 pt qc ro ro2 ru ru_yawerty
#     sapmi sapmi_sefi se si sk sk_qwerty sr syr syr_p
#     tel th tj tml tr_f tr_q tscii
#     ua uk us us_intl uz vn yu
DEF_KEYBOARD=us

# Version identifiers: These should only be changed by the release
# manager as part of making a new release
PKGNAME=mklivecd
MAJORVER=0
MINORVER=5
PATCHVER=6
RELVER=1
CVSVER=yes

# Automatic variable updates, leave alone
MKLIVECDVER=$(MAJORVER).$(MINORVER).$(PATCHVER)
ifeq "$(CVSVER)" "yes"
	CVSDATE=$(shell date +cvs.%Y%m%d)
	MKLIVECDREL=0.$(CVSDATE).$(RELVER)
	ARCHIVEVER=$(MKLIVECDVER)-$(CVSDATE)
else
	MKLIVECDREL=$(RELVER)
	ARCHIVEVER=$(MKLIVECDVER)
endif
KERNELVER=$(shell uname -r)
SPECDATE=$(shell date +"%a %b %e %Y")

# Internal directories: don't edit
DISTDIR=dist
SRCDIR=src
MKLIVECDDIST=$(PKGNAME)-$(ARCHIVEVER)

# Destination directories: you can change the locations for your site either
# here or as an override on the make command-line (preferred)
DESTDIR=
PREFIX=/usr
SBINPREFIX=$(PREFIX)
BINDIR=$(PREFIX)/bin
LIBDIR=$(PREFIX)/lib/$(PKGNAME)
SHAREDIR=$(PREFIX)/share/$(PKGNAME)
DOCDIR=$(PREFIX)/doc/$(PKGNAME)
SBINDIR=$(SBINPREFIX)/sbin
RCDIR=$(SHAREDIR)/init.d

# Utility programs: you can change the locations for your site either
# here or as an override on the make command-line (preferred)
BZIP2=$(shell which bzip2)
CAT=$(shell which cat)
CP=$(shell which cp)
GZIP=$(shell which gzip)
INSTALL=$(shell which install)
MD5SUM=$(shell which md5sum)
MKDIR=$(shell which mkdir)
LN=$(shell which ln)
RM=$(shell which rm)
RPMBUILD=$(shell which rpmbuild)
SED=$(shell which sed)
TAR=$(shell which tar)
TOUCH=$(shell which touch)
