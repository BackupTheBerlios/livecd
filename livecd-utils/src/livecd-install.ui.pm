#############################################################################
# ui.pm extension file, included from the puic-generated form implementation.
# If you wish to add, delete or rename signals or slots use
# the Perl-enabled Qt Designer which will update this file,
# preserving your code.
#
# 'SLOT:' markers are not meant to be created or edited manually.
# Please use the Slots dialog and/or the Object Browser.
#############################################################################

#
# LiveCD-Install script
# Copyright (C) 2003-2004, Jaco Greeff <jaco@linuxminicd.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# The latest version of this script can be found at http://livecd.berlios.de
#
# $Id: livecd-install.ui.pm,v 1.21 2004/01/25 09:33:40 jaco Exp $
#

#use LCDLang;

use threads;
use threads::shared;

use lib qw(/usr/lib/libDrakX);

use fs;
use swap;

my $debug   : shared = undef;
my $nocopy  : shared = undef;

my $destroy : shared = 0;
my $isBusy  : shared = 0;
my $reboot  : shared = 0;

my $prefix : shared = "/tmp";
my $mnt    : shared = "/tmp/livecd.install.$$";
my $log    : shared = "/tmp/livecd.install.log.$$";
my $initrd : shared = "/initrd/loopfs";

my $page = undef;

my $eventloop = undef;

my $rootpart : shared = undef;
my $swappart : shared = undef;
my $homepart : shared = undef;
my $varpart  : shared = undef;
my $tmppart  : shared = undef;
my $bootdev  : shared = undef;

my $infotext      : shared = "";
my $time_o_start  : shared = 0;
my $time_o_end    : shared = 0;
my $time_o_run    : shared = -1;
my $time_f_start  : shared = 0;
my $time_f_end    : shared = 0;
my $time_f_run    : shared = -1;
my $time_c_start  : shared = 0;
my $time_c_end    : shared = 0;
my $time_c_run    : shared = -1;
my $pb_f_num      : shared = 0;
my $pb_f_tot      : shared = 0;
my $pb_c_num      : shared = 0;
my $pb_c_tot      : shared = 0;
my $pb_o_num      : shared = 0;
my $pb_o_tot      : shared = 0;

my %devs   = ();

my %fsnames = (
	'swap'     => 'Linux swap',
	'ext2'     => 'Linux native',
	'reiserfs' => 'Journalised FS: ReiserFS',
	'xfs'      => 'Journalised FS: XFS',
	'jfs'      => 'Journalised FS: JFS',
	'ext3'     => 'Journalised FS: ext3'
);

my %fsopts = (
	'ext2'     => 'defaults',
	'ext3'     => 'defaults',
	'jfs'      => 'defaults',
	'reiserfs' => 'notail,noatime',
	'xfs'      => 'defaults'
);

sub cat_ { local *F; open F, $_[0] or return; my @l = <F>; wantarray() ? @l : join('', @l); };
sub do_system  { my ($p) = @_; print "+ $p {\n"; my $c = system($p); print "+ }=$c\n"; };

sub pageSelected # SLOT: ( const QString & )
{
	my ($title) = @_;

	$page = this->currentPage();
	this->setHelpEnabled($page, 0);
	#this->setCancelEnabled($page, 0);
	doEvents();

	if ($title =~ m/ 1/) {
		this->setFinishEnabled($page, 0);
		doEvents();
	}
	elsif ($title =~ m/ 2/) {
		this->setBackEnabled($page, 0);
		this->setNextEnabled($page, 0);
		doEvents();
		#threads->new(\&scanPartitions, this, $page, \%devs);
		scanPartitions();
		foreach my $dev (sort keys %devs) {
			print "$dev, ".$devs{$dev}{media}.", ".$devs{$dev}{type}."\n";
		}
	}
	elsif ($title =~ m/ 3/) {
		showVerify();
	}
	elsif ($title =~ m/ 4/) {
		this->setBackEnabled($page, 0);
		this->setNextEnabled($page, 0);
		doEvents();
		$time_o_start = time;
		$time_o_run = 1;
		this->startTimer(500);
		threads->new(\&showInstall, this, $page, \%devs);
	}
	elsif ($title =~ m/ 5/) {
		showBootloader();
	}
	elsif ($title =~ m/ 6/) {
		this->setBackEnabled($page, 0);
		this->setNextEnabled($page, 0);
		this->setFinishEnabled($page, 1);
		doEvents();
		$reboot = 0;
	}
}


sub init
{
	select(STDOUT);
	$| = 1;
	
	# initialise our /proc/cmdline
	%cmdline = map {
		chomp;
		my ($name, $value) = split(/=/);
		$name => $value || 1;
	} split(/ /, cat_('/proc/cmdline'));

	# initialise our languages
	#%strings = getStrings();
	#%languages = getLanguages();
	$lang = getMyLang();
	
	print getStr('script_init')."\n";
	do_system("mkdir -p $mnt");
	print getStr('done')."\n";
}


sub destroy
{
	print getStr('script_destroy')."\n";

	# notify threads that we are to die and keep
	# looping until we don't have a thread anymore
	this->killTimers();
	
	$destroy = 1;
	sleep(1) while ($isBusy);

	do_system("umount $mnt/home") if (defined($homepart));
	do_system("umount $mnt/var") if (defined($varpart));
	do_system("umount $mnt/tmp") if (defined($tmppart));
	do_system("umount $mnt && rm -rf $mnt");

	#close(STDERR);
	do_system("rm -rf $log");

	print getStr('done')."\n";
	if ($reboot) {
		print getStr('reboot')."\n";
		exec("/sbin/reboot");
	}
}


sub timerEvent
{
	if ($time_o_run > -1) {
		tlInstInfo->setText($infotext);

		$time_o_end = time if ($time_o_run > -1);
		my $elapsed = $time_o_end - $time_o_start;
		my $elapsed_s = fmtTime($elapsed);
		if ($pb_o_num > 0) {
			my $remain_s = fmtTime(($elapsed/$pb_o_num)*($pb_o_tot-$pb_o_num));
			tlOverall->setText("$elapsed_s Elapsed, $remain_s Remaining");
		}
		else {
			tlOverall->setText("$elapsed_s Elapsed, $elapsed_s Remaining");
		}
		pbOverall->setProgress($pb_o_num, $pb_o_tot);

		$time_f_end = time if ($time_f_run > -1);
		$elapsed = $time_f_end - $time_f_start;
		$elapsed_s = fmtTime($elapsed);
		if ($pb_f_num > 0) {
			my $remain_s = fmtTime(($elapsed/$pb_f_num)*($pb_f_tot-$pb_f_num));
			tlFormat->setText("$elapsed_s Elapsed, $remain_s Remaining");
		}
		else {
			tlFormat->setText("$elapsed_s Elapsed, $elapsed_s Remaining");
		}
		pbFormat->setProgress($pb_f_num, $pb_f_tot);

		$time_c_end = time if ($time_c_run > -1);
		$elapsed = $time_c_end - $time_c_start;
		$elapsed_s = fmtTime($elapsed);
		if ($pb_c_num > 0) {
			my $remain_s = fmtTime(($elapsed/$pb_c_num)*($pb_c_tot-$pb_c_num));
			tlCopy->setText("$elapsed_s Elapsed, $remain_s Remaining");
		}
		else {
			tlCopy->setText("$elapsed_s Elapsed, $elapsed_s Remaining");
		}
		pbCopy->setProgress($pb_c_num, $pb_c_tot);
	}
	else {
		tlInstInfo->setText($infotext);
	}
}


sub scanPartitions
{
    this->setBackEnabled($page, 0);
    this->setNextEnabled($page, 0);

    if (this->cbRoot->count() eq 0) {
	this->cbRoot->insertItem("(none)");
	this->cbRoot->setCurrentItem(0);
	this->cbSwap->insertItem("(none)");
	this->cbSwap->setCurrentItem(0);
	this->cbHome->insertItem("(none)");
	this->cbHome->setCurrentItem(0);
	this->cbVar->insertItem("(none)");
	this->cbVar->setCurrentItem(0);
	this->cbTmp->insertItem("(none)");
	this->cbTmp->setCurrentItem(0);

	do_system("mkdir -p $prefix/etc/livecd/hwdetect");
	do_system("/initrd/usr/sbin/hwdetect --prefix $prefix --fdisk >/dev/null");
	foreach my $line (cat_("$prefix/etc/livecd/hwdetect/mounts.cfg")) {
	    chomp($line);
	    my ($dev, $info) = split(/=\|/, $line, 2);
	    my $devlnk = "/dev/$dev";
	    %{$devs{$devlnk}} = map {
		chomp;
		my ($name, $value) = split(/=/, $_, 2);
		print "$dev: $name = [ $value ]\n";
		$name => $value || 1;
	    } split(/\|/, $info);
	}

	foreach (sort keys %devs) {
	    if ($devs{$_}{type} =~ /ext2/ ||
		$devs{$_}{type} =~ /ext3/ ||
		$devs{$_}{type} =~ /reiserfs/ ||
		$devs{$_}{type} =~ /xfs/ ||
		$devs{$_}{type} =~ /jfs/ ||
		$devs{$_}{type} =~ /swap/) {
		my $size = int((512*$devs{$_}{size})/(1024*1024))."MB";
		my $type = $fsnames{$devs{$_}{type}};
		if ($devs{$_}{type} =~ /swap/) {
		    this->cbSwap->insertItem("$_, $size, $type");
		    this->cbSwap->setCurrentItem(1);
		}
		else {
		    this->cbRoot->insertItem("$_, $size, $type");
		    this->cbHome->insertItem("$_, $size, $type");
		    this->cbVar->insertItem("$_, $size, $type");
		    this->cbTmp->insertItem("$_, $size, $type");
		    this->cbRoot->setCurrentItem(1);
		}
	    }
	}
    }

    this->setBackEnabled($page, 1);
    this->setNextEnabled($page, 1);
}



sub showVerify
{
    if (this->cbRoot->currentText() =~ m/none/) {
	emit back();
	Qt::MessageBox::warning(undef, "Missing root", "You have to specify a root (/) partition", "Retry");
    }
    elsif (this->cbSwap->currentText() =~ m/none/) {
	emit back();
	Qt::MessageBox::warning(undef, "Missing swap", "You have to specify a swap partition", "Retry");
    }
    elsif (!(this->cbHome->currentText() =~ m/none/) &&
           (this->cbHome->currentText() eq this->cbRoot->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, "Overlapping home", "The home (/home) partition is the same as the root (/) partition.", "Retry");
    }
    elsif (!(this->cbVar->currentText() =~ m/none/) &&
           (this->cbVar->currentText() eq this->cbRoot->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, "Overlapping var", "The var (/var) partition is the same as the root (/) partition.", "Retry");
    }
    elsif (!(this->cbVar->currentText() =~ m/none/) &&
           (this->cbVar->currentText() eq this->cbHome->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, "Overlapping var/home", "The var (/var) partition is the same as the home (/home) partition.", "Retry");
    }
    elsif (!(this->cbTmp->currentText() =~ m/none/) &&
           (this->cbTmp->currentText() eq this->cbRoot->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, "Overlapping temp", "The temp (/tmp) partition is the same as the root (/) partition.", "Retry");
    }
    elsif (!(this->cbTmp->currentText() =~ m/none/) &&
           (this->cbTmp->currentText() eq this->cbHome->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, "Overlapping temp", "The temp (/tmp) partition is the same as the home (/home) partition.", "Retry");
    }
    elsif (!(this->cbTmp->currentText() =~ m/none/) &&
           (this->cbTmp->currentText() eq this->cbVar->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, "Overlapping temp/var", "The temp (/tmp) partition is the same as the var (/var) partition.", "Retry");
    }
    else {
	this->lvVerify->clear();
	my $item = undef;
	my $text = undef;
	my @rest = undef;

	$item = Qt::ListViewItem(this->lvVerify, $item);
	$text = this->cbSwap->currentText();
	($swappart, @rest) = split(/,/, $text);
	$item->setText(0, "(swap)");
	$item->setText(1, $text);
	$item->setText(2, "Yes") if (this->cbSwapFormat->isChecked());
	unless (this->cbTmp->currentText() =~ m/none/) {
	    $item = Qt::ListViewItem(this->lvVerify, $item);
	    $text = this->cbTmp->currentText();
	    ($tmppart, @rest) = split(/,/, $text);
	    $item->setText(0, "/tmp");
	    $item->setText(1, $text);
	    $item->setText(2, "Yes") if (this->cbTmpFormat->isChecked());
	}
	unless (this->cbVar->currentText() =~ m/none/) {
	    $item = Qt::ListViewItem(this->lvVerify, $item);
	    $text = this->cbVar->currentText();
	    ($varpart, @rest) = split(/,/, $text);
	    $item->setText(0, "/var");
	    $item->setText(1, $text);
	    $item->setText(2, "Yes") if (this->cbVarFormat->isChecked());
	}
	unless (this->cbHome->currentText() =~ m/none/) {
	    $item = Qt::ListViewItem(this->lvVerify, $item);
	    $text = this->cbHome->currentText();
	    ($homepart, @rest) = split(/,/, $text);
	    $item->setText(0, "/home");
	    $item->setText(1, $text);
	    $item->setText(2, "Yes") if (this->cbHomeFormat->isChecked());
	}
	$item = Qt::ListViewItem(this->lvVerify, $item);
	$text = this->cbRoot->currentText();
	($rootpart, @rest) = split(/,/, $text);
	$item->setText(0, "/");
	$item->setText(1, $text);
	$item->setText(2, "Yes") if (this->cbRootFormat->isChecked());
    }
}


sub showInstall
{
	my ($this, $page, $devs) = @_;

	$isBusy = 1;

	$this->setBackEnabled($page, 0) unless ($destroy);
	$this->setNextEnabled($page, 0) unless ($destroy);
	$infotext = "Scanning available directories" unless ($destroy);

	my $fmtsteps = 0;
	$fmtsteps++ if ($this->cbRootFormat->isChecked());
	$fmtsteps++ if ($this->cbSwapFormat->isChecked());
	$fmtsteps++ if (defined($homepart) && ($this->cbHomeFormat->isChecked()));
	$fmtsteps++ if (defined($varpart) && ($this->cbVarFormat->isChecked()));
	$fmtsteps++ if (defined($tmppart) && ($this->cbTmpFormat->isChecked()));
	if ($fmtsteps) {
		$pb_f_tot = $fmtsteps;
		$pb_f_num = 0;
	}
	else {
		$pb_f_tot = 1;
		$pb_f_num = 1;
	}
	#threads->new(\&timeThread, this, $page, time, this->pbOverall, this->tlOverall) unless ($destroy);

	my @dirs = qx(find $initrd/ -type d | sed -s 's,$initrd,,' | grep -v ^/proc | grep -v ^/dev | grep -v ^/home | grep -v ^/root | grep -v ^/etc) unless ($destroy);
	print "scalar(dirs)=".scalar(@dirs)."\n";
	my $copysteps = scalar(@dirs);

	my @etcdirs = qx(find /etc -type d) unless ($destroy);
	print "scalar(etcdirs)=".scalar(@etcdirs)."\n";
	$copysteps = $copysteps + scalar(@etcdirs);

	my @homedirs = qx(find /home -type d) unless ($destroy);
	print "scalar(homedirs)=".scalar(@homedirs)."\n";
	$copysteps = $copysteps + scalar(@homedirs);

	my @rootdirs = qx(find /root -type d) unless ($destroy);
	print "scalar(rootdirs)=".scalar(@rootdirs)."\n";
	$copysteps = $copysteps + scalar(@rootdirs);

	$pb_c_tot = $copysteps;
	$pb_c_num = 0;

	my $totsteps = $copysteps+$fmtsteps;
	$pb_o_tot = $totsteps;
	$pb_o_num = 0;

	if ($fmtsteps) {
		#threads->new(\&timeThread, this, $page, time, this->pbFormat, this->tlFormat) unless ($destroy);
		$time_f_start = time;
		$time_f_run = 1;
		doFormat($this, $devs) unless ($destroy);
		$time_f_run = -1;
	}

	#threads->new(\&timeThread, this, $page, time, this->pbCopy, this->tlCopy) unless ($destroy);
	unless ($destroy) {
		$time_c_start = time;
		$time_c_run = 1;
		do_system("mkdir -p $mnt");
		do_system("mount -t ".$devs->{$rootpart}{type}." $rootpart $mnt");
		do_system("mkdir -p $mnt/home ; chmod 755 $mnt/home");
		do_system("mkdir -p $mnt/tmp ; chmod 777 $mnt/tmp");
		do_system("mkdir -p $mnt/var ; chmod 755 $mnt/var");
		do_system("mount -t ".$devs->{$homepart}{type}." $homepart $mnt/home") if (defined($homepart));
		do_system("mount -t ".$devs->{$varpart}{type}." $varpart $mnt/var") if (defined($varpart));
		do_system("mount -t ".$devs->{$tmppart}{type}." $tmppart $mnt/tmp") if (defined($tmppart));
	
		do_system("mkdir -p $mnt/initrd ; chmod 755 $mnt/initrd");
		do_system("mkdir -p $mnt/home ; chmod 755 $mnt/home");
		do_system("mkdir -p $mnt/dev ; chmod 755 $mnt/dev");
		do_system("mkdir -p $mnt/proc ; chmod 755 $mnt/proc");
		do_system("mkdir -p $mnt/root/tmp ; chmod -R 755 $mnt/root/tmp");
		do_system("mkdir -p $mnt/tmp ; chmod 777 $mnt/tmp");
		do_system("mkdir -p $mnt/var/lock/subsys ; chmod -R 755 $mnt/var/lock/subsys");
		do_system("mkdir -p $mnt/var/run/netreport ; chmod -R 755 $mnt/var/run/netreport ; touch $mnt/var/run/utmp");
		do_system("cd $mnt/var ; ln -s ../tmp") unless (-e "$mnt/var/tmp");
	}
	
	unless (defined($nocopy)) {
		doCopy($initrd, @dirs) unless ($destroy);
		doCopy("/", @etcdirs) unless ($destroy);
		doCopy("/", @homedirs) unless ($destroy);
		doCopy("/", @rootdirs) unless ($destroy);
	}

	$infotext = "Creating /etc/fstab";
	print "$infotext\n";
	writeFstab($devs) unless ($destroy);

	$infotext = "Installation completed. Please press Next to continue.";
	print "$infotext\n";
	$this->setNextEnabled($page, 1) unless ($destroy);
	sleep(1);

	$isBusy = 0;

	$time_c_run = -1;
	$time_o_run = -1;
	
	print "showInstall(): Done.\n";
}


sub timeThread
{
    my ($page, $start, $pb, $tl) = @_;
#    while (!$destroy && ($pb->progress() ne $pb->totalSteps())) {
#	my $elapsed = time - $start;
#	my $elapsed_s = fmtTime($elapsed);
#	if ($pb->progress() ne 0) {
#	    my $remain_s = fmtTime(($elapsed/$pb->progress())*($pb->totalSteps()-$pb->progress()));
#	    $tl->setText("$elapsed_s Elapsed, $remain_s Remaining") unless ($destroy);
#	}
#	else {
#	    $tl->setText("$elapsed_s Elapsed, $elapsed_s Remaining") unless ($destroy);
#	}
#	sleep(1);
#    }

#    my $elapsed = time - $start;
#    my $elapsed_s = fmtTime($elapsed);
#    my $remain_s = fmtTime(($elapsed/$pb->progress())*($pb->totalSteps()-$pb->progress()));
#    $tl->setText("$elapsed_s Elapsed, $remain_s Remaining") unless ($destroy);
}


sub fmtTime
{
	my ($t) = @_;
	my $h = int($t/3600);
	my $m = int(($t - $h*3600)/60);
	my $s = int($t - $h*3600 - $m*60);
	sprintf("%02d:%02d:%02d", $h, $m, $s);
}


sub doEvents
{
	eval {
		$eventloop = Qt::Application::eventLoop() unless (defined($eventloop));
		$eventloop->processEvents(3, 1) if ($eventloop->hasPendingEvents());
	}
}


sub doFormat
{
	my ($this, $devs) = @_;

	do_system("umount $rootpart");
	formatPart($rootpart, $devs) if ($this->cbRootFormat->isChecked());
	if ($this->cbSwapFormat->isChecked()) {
		do_system("umount $swappart");
		formatPart($swappart, $devs);
	}
	do_system("umount $homepart") if (defined($homepart));
	formatPart($homepart, $devs) if (defined($homepart) && ($this->cbHomeFormat->isChecked()));
	do_system("umount $varpart") if (defined($varpart));
	formatPart($varpart, $devs) if (defined($varpart) && ($this->cbVarFormat->isChecked()));
	do_system("umount $tmppart") if (defined($tmppart));
	formatPart($tmppart, $devs) if (defined($tmppart) && ($this->cbTmpFormat->isChecked()));
}


sub formatPart
{
    my ($dev, $devs) = @_;

    if (!$destroy) {
        print "Formatting:\n$dev (".$fsnames{$devs->{$dev}{type}}.")\n";
	$infotext = "Formatting:\n$dev (".$fsnames{$devs->{$dev}{type}}.")" unless ($destroy);

	if (!defined($debug)) {
		my @options = ();
		#push @options, "-c";
		if ($devs->{$dev}{type} =~ /ext2/) {
			push @options, "-m", "0" if ($dev eq $homepart);
			fs::format_ext2($dev, @options);
		}
		elsif ($devs->{$dev}{type} =~ /ext3/) {
			push @options, "-m", "0" if ($dev eq $homepart);
			fs::format_ext3($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /jfs/) {
			fs::format_jfs($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /reiserfs/) {
			fs::format_reiserfs($dev, @options) ;
		}
			elsif ($devs->{$dev}{type} =~ /xfs/) {
			fs::format_xfs($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /swap/) {
			swap::make($dev, 1);
		}
	}

	$pb_f_num++;
	$pb_o_num++;
    }
}


sub doCopy
{
	my ($from, @dirs) = @_;

	print "DEBUG: doCopy: $from, ".scalar(@dirs)."\n";
	foreach my $dir (@dirs) {
		copyDir($from, $dir);
	}
}


sub copyDir
{
	my ($from, $dir) = @_;

	if (!$destroy) {
		chomp($dir);
		$infotext = "Copying from $from:\n$dir" unless ($destroy);

		if (!defined($debug)) {
			do_system("mkdir -p \"$mnt/$dir\"");
			do_system("chmod \"--reference=$from/$dir\" $mnt/$dir 2>/dev/null");
			do_system("chown \"--reference=$from/$dir\" $mnt/$dir 2>/dev/null");
			do_system("( (cd $from/$dir ; tar --no-recursion --exclude .. -c * .*) | (cd $mnt/$dir ; tar -x) ) 2>/dev/null");
		}

		$pb_c_num++;
		$pb_o_num++;
	}
}


sub showBootloader
{
	this->setBackEnabled($page, 0);
	this->lbBootloader->insertItem("$rootpart (Bootsector of partition)");

	my @drives = ();
	foreach my $dev (sort keys %devs) {
		if ($devs{$dev}{media} =~ /hd/) {
		$dev =~ s/[0-9]//;
		my $found = 0;
		foreach my $in (@drives) {
			$found = 1 if ($in eq $dev);
		}
		push @drives, $dev unless ($found);
		}
	}
	this->lbBootloader->insertItem("$_ (Master boot record of drive)") foreach (@drives);
	this->lbBootloader->setCurrentItem(0);
}


sub doLoaderInstall # SLOT: ( )
{
	if (!defined($debug)) {
		my $kernelver = qx(uname -r);
		chomp($kernelver);
		my $kernel = "/boot/vmlinuz-".$kernelver;
		my $initrd = "/boot/initrd-".$kernelver.".img";
		my $distro = qx(cat /etc/redhat-release | awk '{ print \$1 }');
		chomp($distro);

		my $bootstr = lbBootloader->selectedItem()->text();
		my ($bdev, $text) = split(/ /, $bootstr);
		$bootdev = $bdev;

		my $kbdmap = "$mnt/usr/lib/kbd/keymaps/livecd.map";
		do_system("mkdir -p $mnt/usr/lib/kbd/keymaps ; dumpkeys >$kbdmap");
		do_system("keytab-lilo.pl $kbdmap $kbdmap >$mnt/boot/livecd.klt");
		
		do_system("mkdir -p $mnt/etc");
		open LILO, '>', "$mnt/etc/lilo.conf";
		print LILO "boot=$bootdev
map=/boot/map
default=\"$distro\"
keytable=/boot/livecd.klt
prompt
nowarn
timeout=100
message=/boot/message
menu-scheme=wb:bw:wb:bw
image=$kernel
	label=\"$distro\"
	root=$rootpart
	initrd=$initrd
	append=\"devfs=mount splash=silent\"
	vga=791
	read-only
";
		close LILO;
		do_system("mount -t proc none $mnt/proc");
		do_system("mount -t devfs none $mnt/dev");
		do_system("rm -rf $mnt/$initrd");
		do_system("mkdir -p $mnt/root/tmp");
		my $with = "";
		do_system("chroot $mnt /sbin/mkinitrd -v $with $initrd $kernelver");
		do_system("/sbin/lilo -v -r $mnt");
		do_system("umount $mnt/dev");
		do_system("umount $mnt/proc");
	}

	emit this->next();
}


sub writeFstab {
	my ($devs) = @_;

	if (!defined($debug)) {
		my @fstab = fs::read_fstab("", "/etc/fstab");
		my $hdds = {};
		fs::add2all_hds($hdds, @fstab);
		fs::write_fstab($hdds, $mnt);

		open FSTAB, '>', "$mnt/etc/fstab";
		print FSTAB "\n### entries below this line were automatically added by LiveCD install\n";
		print FSTAB "\nnone"."\t"."/proc"."\t"."proc"."\t"."defaults"."\t"."0 0";
		print FSTAB "\nnone"."\t"."/dev"."\t"."devfs"."\t"."defaults"."\t"."0 0";
		print FSTAB "\n";

		print "DEBUG: rootpart=$rootpart\n";
		print "DEBUG: homepart=$homepart\n";
		print "DEBUG: varpart=$varpart\n";
		print "DEBUG: tmppart=$tmppart\n";
		foreach my $dev (sort keys %$devs) {
			print "FSTAB: Adding $dev\n";
			my $devpnt = $dev;
			$devpnt =~ s|/dev/||;

			my $mount = "";
			my $opt = undef;
			if ($dev eq $rootpart) {
				$mount = "/";
				$opt = $fsopts{$devs->{$dev}{type}};
			}
			elsif ($dev eq $homepart) {
				$mount = "/home";
				$opt = $fsopts{$devs->{$dev}{type}};
			}
			elsif ($dev eq $varpart) {
				$mount = "/var";
				$opt = $fsopts{$devs->{$dev}{type}};
			}
			elsif ($dev eq $tmppart) {
				$mount = "/tmp";
				$opt = $fsopts{$devs->{$dev}{type}};
			}
			else {
				do_system("mkdir -p $mnt/mnt/$devpnt 2>/dev/null");
				$mount = $devs->{$dev}{mount};
				unless ($devs->{$dev}{supermount}) {
					$opt = $devs->{$dev}{opt};
				}
				else {
					$opt = "dev=".$devs->{$dev}{dev}.",fs=udf:iso9660,";
					$opt .= $devs->{$dev}{opt} if ($devs->{$dev}{opt});
				}
			}

			my $entry = "\n# ".$devs->{$dev}{info}."\n";
			unless ($devs->{$dev}{supermount}) {
				$entry .= $devs->{$dev}{dev}."\t";
				$entry .= $mount."\t";
				$entry .= $devs->{$dev}{type}."\t";
			}
			else {
				$entry .= "none\t";
				$entry .= $mount."\t";
				$entry .= "supermount\t";
			}
			$opt = "" unless ($opt);
			$opt .= "," if ($devs->{$dev}{opt} && $devs->{$dev}{extopt});
			$opt .= $devs->{$dev}{extopt} if ($devs->{$dev}{extopt});
			$entry .= $opt."\t"."0 0\n";
			print FSTAB $entry;
			print "FSTAB: $entry";
		}
		close FSTAB;
	}
}


sub toggleReboot # SLOT: ( bool )
{
	my ($check) = @_;

	$reboot = $check;
	print "check: $check, reboot: $reboot\n";
}

