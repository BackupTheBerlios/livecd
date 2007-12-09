
%define name		mklivecd
%define version		0.6.0
#%define snapshot	20070723
%define release		%mkrel 34

%define _requires_exceptions perl-base

%define summary	Builds a LiveCD from an existing PCLinuxOS installation

Summary:	%{summary}
Name:		%{name}
Version:	%{version}
Release:	%{release}
License:	GPL
Group:		System/Configuration/Boot and Init
URL:		http://livecd.berlios.de/
Source0:	%{name}-0.6.0-20071202.tar.bz2
Requires:	busybox >= 1.6.1
Requires:	mediacheck, cdrkit-genisoimage, squashfs-tools >= 1.4-0.1
Requires:	syslinux >= 1.76-15
BuildRoot:	%{_tmppath}/%{name}-root
Buildarch:	i586

%description
The mklivecd tools are dedicated to providing you with the capability to
create your own LiveCD or LiveDVD from a currently installed PCLOS distribution.
It can be used to create your own travelling PCLinuxOS-based LiveCD, specialised
LiveCD featuring custom-developed applications or to put together a demo disk
to show off the power of our favourite OS. The possibilities are endless!

Created CD's feature automatic hardware detection and setup. In addition, it
utilises compression technology allowing you to build a LiveCD from a partition
much larger than will typically fit on a CD or DVD.(Up to 2GB for a normal 650MB CD
or around 10GB for a normal 4GB DVD) When booting from this LiveCD, the data is
transparently decompressed as needed with almost no performance impact.

%prep
%setup -q -n %{name}-0.6.0-20071202

%build
%make

%install
rm -rf %buildroot
%makeinstall_std

%clean
rm -rf %buildroot

%files
%defattr(-,root,root)
%doc AUTHORS COPYING CHANGELOG FAQ README README.BOOTCODES README.USB TODO
%{_sbindir}/mklivecd
%{_sbindir}/hwdetect
%dir %{_datadir}/mklivecd
%{_datadir}/mklivecd/linuxrc
%{_datadir}/mklivecd/halt.local
%{_datadir}/mklivecd/rc.sysinit

%changelog
* Sun DEc 2 2007 ikerekes
- improve sata drive search (extend beyond sd[a-b]
- improve changes=loopfile (don't limit to ext2)

* Fri Nov 30 2007 ikerekes
- change=<dev>/<loopfile> ext2 loopmounted file, can reside on vfat (usb stick) or any linux fs.
- Brian's bootfrom mod in the halt.local

* Mon Oct 22 2007 etjr
- i18n-framework from i18n team at mypclinuxos.com

* Thu Aug 30 2007 etjr
- added "Boot_from_Hard-disk" label per Ivan

* Sun Aug 19 2007 etjr
- corrected usb-storage and bootsplash code per Ivan

* Sat Aug 18 2007 etjr
- many changes by Ivan
- linuxrc.in
-   moved $SETCOLOR_NORMAL
- halt.local.in
-   removed mount of proc

* Tue Aug 7 2007 etjr
- Modules.mk and modprobe changes per Ivan

* Tue Jul 24 2007 etjr
- change the spec back for make rpm

* Fri Jul 20 2007 ocilent1 <ocilent1 at gmail dot com>
- some further insmod cleanups
- tweak spec file a bit

* Fri Jul 20 2007 etjr
- fix insmod for new modules-init-tools-3

* Tue Jul 10 2007 etjr
- changes to use mdev or udevstart

* Sun Jul 8 2007 etjr
- changes for mdev (busybox mdev) - Thanks Gentoo

* Sat Jun 2 2007 etjr
- hwdetect.in
- changes in nofinishinstall
- removed "&" from config_*()

* Fri May 11 2007 Texstar <texstar@gmail.com> 
- add VideoSafeModeFBDev and VideoSafeModeVesa
- in mklivecd and hwdetect

* Fri May 11 2007 Texstar <texstar@gmail.com> 
- change safe mode to use vesa driver instead of fbdev

* Sun May 6 2007 etjr
- hwdetect.in
-  added "&" to config_*(); to suppress verbose bootup  warnings
-  remove duplicate "my $modules_conf" & "my %cmdline" entries
-  remove "my $cdsymlinks" /etc/udev/scripts/cdsymlinks.sh deprecated?
-  fixed - mkdir_p("$prefix/etc/livecd/hwdetect/");
- mklivecd.in
-  added /media$ to $nodirs
- linuxrc.in
-  added mkdir -p /media

* Sat May 5 2007 etjr
- merge in sata changes in hwdetect per Ivan

* Thu May 3 2007 etjr
- changes for moved modules with kernel 2.6.20
- removed 2.4 kernel modules
- removed more unused code

* Mon Apr 30 2007 Texstar <texstar@gmail.com> 
- merge in changes to hwdetect per Ivan

* Wed Mar 28 2007 etjr
- moved /dev/sd[a-b][0-99] first for usb per Nico
- ramdisk size change from 1/3 to 1/2 per Nico

* Sat Mar 24 2007 etjr
- add changelog to spec file

* Tue Mar 6 2007 etjr
- suppress "bootsplash not found ..." warning
- remove some unused code
- --ufs defaults to aufs

* Sat Feb 3 2007 etjr
- hwdetect.in
- changed back config_network();
- hwdetect-lang.in
- changed back 'network probe'

* Fri Feb 2 2007 etjr
- mklivecd.in
- added more excluded files
- change mkisofs to genisoimage
- change blocksize to 224
- change default bootloader back to iso
- change label Framebuffer to VideoSafeMode in iso and grub
- hwdetect.in
- remove config_network();
- hwdetect-lang.in
- remove 'network probe'
- linuxrc.in
- moved "##Probe the scsi devices." section per Ivan
- Cleaned out some unused lines 

* Tue Dec 12 2006 etjr
- added option --ufs to create livecd with unionfs or aufs
- added rc.sysinit.aufs.in
- rc.sysinit.in - create ifcfg-eth0
- hwdetect.in - Texstar's config_network fix
- mklivecd.in
- exclude files ifcfg-eth0, 61-*config.rules, and modprobe.conf
- gfxboot changes
- default to grub

Jaco Greeff <jaco@puxedo.org> 0.6.0-20070506.1
- version 0.6.0-20070506
- updated description
- added squashfs-tools require
- updated requires to include version numbers where earlier versions won't work

* Wed Dec 03 2003 Per Ãyvind Karlsen <peroyvind@linux-mandrake.com> 0.5.6-2mdk
- spec fixes
- fix unowned dir

* Mon Oct  6 2003 Jaco Greeff <jaco@linuxminicd.org> 0.5.6-1mdk
- version 0.5.6
- spec fixes by Buchan Milne <bgmilne@cae.co.za>

* Sat Sep 27 2003 Tibor Pittich <Tibor.Pittich@phuture.sk> 0.5.5-2mdk
- rebuild

* Thu Sep 25 2003 Jaco Greeff <jaco@linuxminicd.org> 0.5.5-1mdk
- version 0.5.5

* Wed Sep 24 2003 Tibor Pittich <Tibor.Pittich@phuture.sk> 0.5.4-2mdk
- spec fixes

* Tue Sep 23 2003 Jaco Greeff <jaco@linuxminicd.org> 0.5.4-1mdk
- version 0.5.4
- removed patch0, fixed upstream

* Mon Sep 22 2003 Tibor Pittich <Tibor.Pittich@phuture.sk> 0.5.3-1mdk
- initial import into contrib, based on spec file from Jaco Greeff
- fixed requires (mkisofs)
- temporary locale fix to correct calculate initrd size
- correct mdk group name
- some macroszification
