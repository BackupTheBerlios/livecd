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
# $Id: livecd-install.ui.pm,v 1.50 2004/12/21 19:30:32 tom_kelly33 Exp $
#

#use LCDLang;

use strict;
use threads;
use threads::shared;

use lib qw(/usr/lib/libDrakX);

use fs;

my $debug   : shared = undef;
my $nocopy  : shared = undef;

if ($opt_debug) {$debug = 1};
if ($opt_nocopy) {$nocopy = 1};

my $destroy : shared = 0;
my $isBusy  : shared = 0;
my $reboot  : shared = 0;

my $prefix : shared = "/tmp";
my $mnt    : shared = "/tmp/livecd.install.$$";
my $log    : shared = "/tmp/livecd.install.log.$$";
my $initrd : shared = "/initrd/loopfs";

my $kernel26	: shared = undef;

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
	'reiser4'  => 'Journalised FS: Reiser4',
	'xfs'      => 'Journalised FS: XFS',
	'jfs'      => 'Journalised FS: JFS',
	'ext3'     => 'Journalised FS: ext3'
);

my %fsopts = (
	'ext2'     => 'defaults',
	'ext3'     => 'defaults',
	'jfs'      => 'defaults',
	'reiserfs' => 'notail,noatime',
	'reiser4'  => 'notail,noatime',
	'xfs'      => 'defaults'
);

sub cat_ { local *F; open F, $_[0] or return; my @l = <F>; wantarray() ? @l : join('', @l); };
sub do_system   { my ($p) = @_; print "+ $p {\n"; my $c = system($p); print "+ }=$c\n"; };
sub do_system2  { my ($p) = @_; print "+ $p {\n"; my $c = system($p); print "+ }=$c\n"; return $c; };

sub pageSelected # SLOT: ( const QString & )
{
	my ($title) = @_;

	$page = this->currentPage();
	this->setHelpEnabled($page, 0);
	#this->setCancelEnabled($page, 0);
	doEvents();

	if ($title =~ m/ 1/) {
		this->setFinishEnabled($page, 0);

		## Setup language list
		cbLanguage->clear();
		cbLanguage->insertItem('Language');
		cbLanguage->setCurrentItem(0);
		cbLanguage->insertItem('Deutsch - de');
		cbLanguage->setCurrentItem(1);
		cbLanguage->insertItem('English - en');
		cbLanguage->setCurrentItem(1);
		cbLanguage->insertItem('francais - fr');
		cbLanguage->setCurrentItem(1);
		cbLanguage->insertItem('italiano - it');
		cbLanguage->setCurrentItem(1);
		cbLanguage->insertItem('Turkish - tr');
		cbLanguage->setCurrentItem(1);
		cbLanguage->insertItem('Vietnamese - vi');
		cbLanguage->setCurrentItem(0); ## Language 1st item

		## Make mount, remove swap and nfs
		do_system("mkdir -p $mnt");  # make mountpoint
		do_system2("swapoff -a");    # swap may change
		do_system2("umount -a -t nfs"); # don't want to copy nfs dirs

		doEvents();
	}
	elsif ($title =~ m/ 2/) {
		this->setBackEnabled($page, 0);
		this->setNextEnabled($page, 0);
		doEvents();
		#threads->new(\&scanPartitions, this, $page, \%devs);
		scanPartitions();
		print "\n Scan Partition results:\n";
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
		#this->setBackEnabled($page, 0);
		this->setNextEnabled($page, 0);
		this->setFinishEnabled($page, 1);
		doEvents();
		$reboot = 0;
	}
}

sub initLang 
{
	setCaption(getStr('caption'));
	
	setTitle(page, getStr('scr_1_title'));
	tbWelcome->setText(getStr('scr_1_text'));
	bDiskPartitioner->setText(getStr('btn_disk_part'));

	setTitle(page_2, getStr('scr_2_title'));
	tlWelcome_2_3->setText(getStr('scr_2_text'));
	groupBox16->setTitle(getStr('scr_2_req'));
	textLabel5->setText(getStr('scr_2_swap'));
	textLabel1->setText(getStr('scr_2_root'));
	groupBox16_2->setTitle(getStr('scr_2_opt'));
	textLabel1_2->setText(getStr('scr_2_home'));
	textLabel5_2->setText(getStr('scr_2_var'));
	textLabel5_2_2->setText(getStr('scr_2_tmp'));
	cbTmpFormat->setText(getStr('scr_2_fmt'));
	cbVarFormat->setText(getStr('scr_2_fmt'));
	cbHomeFormat->setText(getStr('scr_2_fmt'));
	cbRootFormat->setText(getStr('scr_2_fmt'));
	cbSwapFormat->setText(getStr('scr_2_fmt'));
	
	setTitle(page_3, getStr('scr_3_title'));
	textLabel1_3->setText(getStr('scr_3_text'));
	lvVerify->header()->setLabel(0, getStr('scr_3_mnt'));
	lvVerify->header()->setLabel(1, getStr('scr_3_dev'));
	lvVerify->header()->setLabel(2, getStr('scr_3_fmt'));
	lvVerify->clear();
	my $item = Qt::ListViewItem(lvVerify, undef);
	
	setTitle(page_4, getStr('scr_4_title'));
	textLabel1_3_2->setText(getStr('scr_4_text'));
	tlInstInfo->setText("");
	groupBox3->setTitle(getStr('scr_4_progress'));
	textLabel2->setText(getStr('scr_4_fmt'));
	textLabel2_2->setText(getStr('scr_4_copy'));
	textLabel2_2_2->setText(getStr('scr_4_overall'));
	tlOverall->setText("00:00:00 ".getStr('time_elapsed').", 00:00:00 ".getStr('time_remaining'));
	tlFormat->setText("00:00:00 ".getStr('time_elapsed').", 00:00:00 ".getStr('time_remaining'));
	tlCopy->setText("00:00:00 ".getStr('time_elapsed').", 00:00:00 ".getStr('time_remaining'));

	# Page 5	
	setTitle(page_5, getStr('scr_5_title'));
	textLabel1_3_2_2->setText(getStr('scr_5_text'));
        textLabel52->setText(getStr('scr_52'));
	bInstall->setText(getStr('btn_inst'));
	bLogging_yes->setText(getStr('btn_logging_yes'));
	bLogging_no->setText(getStr('btn_logging_no'));
 
	# Page 6	
	setTitle(page_6, getStr('scr_6_title'));
	tlWelcome_2->setText(getStr('scr_6_text'));

	textLabel611->setText(getStr('scr_6_typeroot'));
	textLabel612->setText(getStr('scr_6_typeroot2'));
	bWritePassword->setText(getStr('btn_write_pw'));

        textLabel621->setText(getStr('scr_6_del_guest'));
        bDeleteGuest->setText(getStr('btn_del_guest'));

        textLabel631->setText(getStr('scr_6_add_user'));
        textLabel632->setText(getStr('scr_6_au_login'));
        textLabel633->setText(getStr('scr_6_au_real'));
        textLabel634->setText(getStr('scr_6_au_pw'));
        textLabel635->setText(getStr('scr_6_au_rpw'));
        bCreateUser->setText(getStr('btn_cr_user'));

        buttonGroup2->setTitle( "" );
        rbNoReboot->setText(getStr('scr_6_no'));
        rbReboot->setText(getStr('scr_6_yes'));

}

sub init
{
	select(STDOUT);
 	$| = 1;

	if (index(qx(uname -r), "2.6") eq '0') {  # "2.6_____"
		$kernel26 = 1;
	}

	# initialise our languages
	#$lang = getMyLang();
	if ($lang eq '') {$lang = getMyLang() };
	print getStr('script_init')."\n";
	initLang();
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
	print "\nunmounting \n";
	do_system("umount -l $mnt/home") if (defined($homepart));
	do_system("umount -l $mnt/var") if (defined($varpart));
	do_system("umount -l $mnt/tmp") if (defined($tmppart));
	do_system("umount -l $mnt && rm -rf $mnt");

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
			tlOverall->setText("$elapsed_s ".getStr('time_elapsed').", $remain_s ".getStr('time_remaining'));
		}
		else {
			tlOverall->setText("$elapsed_s ".getStr('time_elapsed').", $elapsed_s ".getStr('time_remaining'));
		}
		pbOverall->setProgress($pb_o_num, $pb_o_tot);

		$time_f_end = time if ($time_f_run > -1);
		$elapsed = $time_f_end - $time_f_start;
		$elapsed_s = fmtTime($elapsed);
		if ($pb_f_num > 0) {
			my $remain_s = fmtTime(($elapsed/$pb_f_num)*($pb_f_tot-$pb_f_num));
			tlFormat->setText("$elapsed_s ".getStr('time_elapsed').", $remain_s ".getStr('time_remaining'));
		}
		else {
			tlFormat->setText("$elapsed_s ".getStr('time_elapsed').", $elapsed_s ".getStr('time_remaining'));
		}
		pbFormat->setProgress($pb_f_num, $pb_f_tot);

		$time_c_end = time if ($time_c_run > -1);
		$elapsed = $time_c_end - $time_c_start;
		$elapsed_s = fmtTime($elapsed);
		if ($pb_c_num > 0) {
			my $remain_s = fmtTime(($elapsed/$pb_c_num)*($pb_c_tot-$pb_c_num));
			tlCopy->setText("$elapsed_s ".getStr('time_elapsed').", $remain_s ".getStr('time_remaining'));
		}
		else {
			tlCopy->setText("$elapsed_s ".getStr('time_elapsed').", $elapsed_s ".getStr('time_remaining'));
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

    # Clear old values, if any
	%devs = ();
	this->cbRoot->clear();
	this->cbSwap->clear();
	this->cbHome->clear();
	this->cbVar->clear();
	this->cbTmp->clear();

	this->cbRoot->insertItem(getStr('part_none'));
	this->cbRoot->setCurrentItem(0);
	this->cbSwap->insertItem(getStr('part_none'));
	this->cbSwap->setCurrentItem(0);
	this->cbHome->insertItem(getStr('part_none'));
	this->cbHome->setCurrentItem(0);
	this->cbVar->insertItem(getStr('part_none'));
	this->cbVar->setCurrentItem(0);
	this->cbTmp->insertItem(getStr('part_none'));
	this->cbTmp->setCurrentItem(0);

	do_system("mkdir -p $prefix/etc/livecd/hwdetect");
	do_system("/initrd/usr/sbin/hwdetect --prefix $prefix --fdisk >/dev/null");
	print "\n Scan Partitions\n";
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
		$devs{$_}{type} =~ /reiser4/ ||
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

    this->setBackEnabled($page, 1);
    this->setNextEnabled($page, 1);
}



sub showVerify
{
    my $none = getStr('part_none'); # For translations

    if (this->cbRoot->currentText() =~ m/$none/) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_no_root_t'), getStr('part_no_root'), getStr('btn_retry'));
    }
    elsif (this->cbSwap->currentText() =~ m/$none/) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_no_swap_t'), getStr('part_no_swap'), getStr('btn_retry'));
    }
    elsif (!(this->cbHome->currentText() =~ m/$none/) &&
           (this->cbHome->currentText() eq this->cbRoot->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_o_home_t'), getStr('part_o_home'), getStr('btn_retry'));
    }
    elsif (!(this->cbVar->currentText() =~ m/$none/) &&
           (this->cbVar->currentText() eq this->cbRoot->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_o_var_t'), getStr('part_o_var'), getStr('btn_retry'));
    }
    elsif (!(this->cbVar->currentText() =~ m/$none/) &&
           (this->cbVar->currentText() eq this->cbHome->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_o_varhome_t'), getStr('part_o_varhome'), getStr('btn_retry'));
    }
    elsif (!(this->cbTmp->currentText() =~ m/$none/) &&
           (this->cbTmp->currentText() eq this->cbRoot->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_o_tmp_t'), getStr('part_o_tmp'), getStr('btn_retry'));
    }
    elsif (!(this->cbTmp->currentText() =~ m/$none/) &&
           (this->cbTmp->currentText() eq this->cbHome->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_o_tmphome_t'), getStr('part_o_tmphome'), getStr('btn_retry'));
    }
    elsif (!(this->cbTmp->currentText() =~ m/$none/) &&
           (this->cbTmp->currentText() eq this->cbVar->currentText())) {
	emit back();
	Qt::MessageBox::warning(undef, getStr('part_o_tmpvar_t'), getStr('part_o_tmpvar'), getStr('btn_retry'));
    }
    else {
	this->lvVerify->clear();
	my $item = undef;
	my $text = undef;
	my @rest = undef;

	$item = Qt::ListViewItem(this->lvVerify, $item);
	$text = this->cbSwap->currentText();
	($swappart, @rest) = split(/,/, $text);
	$item->setText(0, getStr('part_name_swap'));
	$item->setText(1, $text);
	$item->setText(2, getStr('yes')) if (this->cbSwapFormat->isChecked());
	unless (this->cbTmp->currentText() =~ m/$none/) {
	    $item = Qt::ListViewItem(this->lvVerify, $item);
	    $text = this->cbTmp->currentText();
	    ($tmppart, @rest) = split(/,/, $text);
	    $item->setText(0, getStr('part_name_tmp'));
	    $item->setText(1, $text);
	    $item->setText(2, getStr('yes')) if (this->cbTmpFormat->isChecked());
	}
	unless (this->cbVar->currentText() =~ m/$none/) {
	    $item = Qt::ListViewItem(this->lvVerify, $item);
	    $text = this->cbVar->currentText();
	    ($varpart, @rest) = split(/,/, $text);
	    $item->setText(0, getStr('part_name_var'));
	    $item->setText(1, $text);
	    $item->setText(2, getStr('yes')) if (this->cbVarFormat->isChecked());
	}
	unless (this->cbHome->currentText() =~ m/$none/) {
	    $item = Qt::ListViewItem(this->lvVerify, $item);
	    $text = this->cbHome->currentText();
	    ($homepart, @rest) = split(/,/, $text);
	    $item->setText(0, getStr('part_name_home'));
	    $item->setText(1, $text);
	    $item->setText(2, getStr('yes')) if (this->cbHomeFormat->isChecked());
	}
	$item = Qt::ListViewItem(this->lvVerify, $item);
	$text = this->cbRoot->currentText();
	($rootpart, @rest) = split(/,/, $text);
	$item->setText(0, getStr('part_name_root'));
	$item->setText(1, $text);
	$item->setText(2, getStr('yes')) if (this->cbRootFormat->isChecked());
    }
}


sub showInstall
{
	my ($this, $page, $devs) = @_;

	$isBusy = 1;

	$this->setBackEnabled($page, 0) unless ($destroy);
	$this->setNextEnabled($page, 0) unless ($destroy);
	$infotext = getStr('inst_scan') unless ($destroy);

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

	my @dirs = qx(find $initrd/ -type d -mount | sed -s 's,$initrd,,' | grep -v ^/proc | grep -v ^/dev | grep -v ^/home | grep -v ^/root | grep -v ^/etc | grep -v ^/lib/dev-state) unless ($destroy);
	print "scalar(dirs)=".scalar(@dirs)."\n";
	my $copysteps = scalar(@dirs);

	my @etcdirs = qx(find /etc -type d -mount) unless ($destroy);
	print "scalar(etcdirs)=".scalar(@etcdirs)."\n";
	$copysteps = $copysteps + scalar(@etcdirs);

	my @homedirs = qx(find /home -type d -mount) unless ($destroy);
	print "scalar(homedirs)=".scalar(@homedirs)."\n";
	$copysteps = $copysteps + scalar(@homedirs);

	my @rootdirs = qx(find /root -type d -mount) unless ($destroy);
	print "scalar(rootdirs)=".scalar(@rootdirs)."\n";
	$copysteps = $copysteps + scalar(@rootdirs);

	my @devstatedirs = qx(find /lib/dev-state -type d -mount) unless ($destroy);
	print "scalar(devstatedirs)=".scalar(@devstatedirs)."\n";
	$copysteps = $copysteps + scalar(@devstatedirs);

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
		#do_system("rm -f $mnt/etc/mtab ; touch $mnt/etc/mtab");
		do_system("touch $mnt/halt");
		do_system("cd $mnt/var ; ln -s ../tmp") unless (-e "$mnt/var/tmp");
	}
	
	unless (defined($nocopy)) {
		doCopy($initrd, @dirs) unless ($destroy);
		doCopy("/", @etcdirs) unless ($destroy);
		doCopy("/", @homedirs) unless ($destroy);
		doCopy("/", @rootdirs) unless ($destroy);
		doCopy("/", @devstatedirs) unless ($destroy);

	}

	$infotext = getStr('inst_fstab');
	print "$infotext\n";
	writeFstab($devs) unless ($destroy);

	# re-establish original inittab
	do_system("cp -a /initrd/etc/inittab $mnt/etc/");

	$infotext = getStr('inst_done');
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

	do_system2("umount -l $devs->{$rootpart}{mount}");
	formatPart($rootpart, $devs) if ($this->cbRootFormat->isChecked());
	if ($this->cbSwapFormat->isChecked()) {
		print getStr('fmt_title')."\n$swappart (".$fsnames{$devs->{$swappart}{type}}.")\n";
		$infotext = getStr('fmt_title')."\n$swappart (".$fsnames{$devs->{$swappart}{type}}.")" unless ($destroy);
		do_system2("mkswap -c $swappart");
		do_system2("swapon $swappart");
		$pb_f_num++;
		$pb_o_num++;
	}
	do_system2("umount -l $devs->{$homepart}{mount}") if (defined($homepart));
	formatPart($homepart, $devs) if (defined($homepart) && ($this->cbHomeFormat->isChecked()));
	do_system2("umount -l $devs->{$varpart}{mount}") if (defined($varpart));
	formatPart($varpart, $devs) if (defined($varpart) && ($this->cbVarFormat->isChecked()));
	do_system2("umount -l $devs->{$tmppart}{mount}") if (defined($tmppart));
	formatPart($tmppart, $devs) if (defined($tmppart) && ($this->cbTmpFormat->isChecked()));
}


sub formatPart
{
    my ($dev, $devs) = @_;

    if (!$destroy) {
        print getStr('fmt_title')."\n$dev (".$fsnames{$devs->{$dev}{type}}.")\n";
	$infotext = getStr('fmt_title')."\n$dev (".$fsnames{$devs->{$dev}{type}}.")" unless ($destroy);

	if (!defined($debug)) {
		my @options = ();
		#push @options, "-c";
		if ($devs->{$dev}{type} =~ /ext2/) {
			push @options, "-m", "0" if ($dev eq $homepart);
			format_ext2($dev, @options);
		}
		elsif ($devs->{$dev}{type} =~ /ext3/) {
			push @options, "-m", "0" if ($dev eq $homepart);
			format_ext3($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /jfs/) {
			format_jfs($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /reiserfs/) {
			format_reiserfs($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /reiser4/) {
			# fs::format_reiser4($dev, @options);
		}
			elsif ($devs->{$dev}{type} =~ /xfs/) {
			format_xfs($dev, @options);
		}
	}

	$pb_f_num++;
	$pb_o_num++;
    }
}

sub format_ext2($@) {
    my ($dev, @options) = @_;
    $dev =~ m,(rd|ida|cciss)/, and push @options, qw(-b 4096 -R stride=16); #- For RAID only.
    run_program::raw({ timeout => 60 * 60 }, 'mke2fs', '-F', @options, devices::make($dev)) or die N("%s formatting of %s failed", (any { $_ eq '-j' } @options) ? "ext3" : "ext2", $dev);
}
sub format_ext3 {
    my ($dev, @options) = @_;
    format_ext2($dev, "-j", @options);
    run_program::run("tune2fs", "-c0", "-i0", devices::make($dev));
}
sub format_reiserfs {
    my ($dev, @options) = @_;
    run_program::raw({ timeout => 60 * 60 }, "mkreiserfs", "-ff", @options, devices::make($dev)) or die N("%s formatting of %s failed", "reiserfs", $dev);
}
sub format_xfs {
    my ($dev, @options) = @_;
    run_program::raw({ timeout => 60 * 60 }, "mkfs.xfs", "-f", "-q", @options, devices::make($dev)) or die N("%s formatting of %s failed", "xfs", $dev);
}
sub format_jfs {
    my ($dev, @options) = @_;
    run_program::raw({ timeout => 60 * 60 }, "mkfs.jfs", "-f", @options, devices::make($dev)) or die N("%s formatting of %s failed", "jfs", $dev);
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
		$infotext = getStr('copy_title')." $from:\n$dir" unless ($destroy);

		if (!defined($debug)) {
			do_system("mkdir -p \"$mnt/$dir\"");
			do_system("chmod \"--reference=$from/$dir\" \"$mnt/$dir\" 2>/dev/null");
			do_system("chown \"--reference=$from/$dir\" \"$mnt/$dir\" 2>/dev/null");
			do_system("( (cd \"$from/$dir\" ; tar --no-recursion --exclude .. -c * .*) | (cd \"$mnt/$dir\" ; tar -x) ) 2>/dev/null");
		}
		$pb_c_num++;
		$pb_o_num++;
	}
}


sub showBootloader
{
   if (!defined($debug)) {
	my $kernelver = qx(uname -r);
	chomp($kernelver);
	my $kernel = "/boot/vmlinuz-".$kernelver;
	my $initrd = "/boot/initrd-".$kernelver.".img";
	my $distro = qx(cat /etc/redhat-release | awk '{ print \$1 }');
	chomp($distro);
	do_system("mount -t proc none $mnt/proc");
	if ($kernel26 eq "1") {
		do_system("cp -a /dev $mnt");
		do_system("mount -t none /dev $mnt/dev -o bind");
	} else {
		do_system("mount -t devfs none $mnt/dev"); # Mount for devfs
	}
	do_system("rm -rf $mnt/$initrd");
	do_system("mkdir -p $mnt/root/tmp");
	my $with = "";
	do_system("chroot $mnt /sbin/mkinitrd -v $with $initrd $kernelver");
	do_system("umount $mnt/dev");
	do_system("umount $mnt/proc");

	this->setBackEnabled($page, 0);
	this->lbBootloader->clear();
	this->lbBootloader->insertItem("$rootpart ".getStr('boot_bs'));

	my @drives = ();
	foreach my $dev (sort keys %devs) {
	    if ($devs{$dev}{media} =~ /hd/) {
		#$dev =~ s/[0-9]//;
		while ( substr($dev, -1) =~ /[0-9]/) {
			substr($dev, -1) = "";
		};
		my $found = 0;
		foreach my $in (@drives) {
			$found = 1 if ($in eq $dev);
		}
		push @drives, $dev unless ($found);
	    }
	}
	this->lbBootloader->insertItem("$_ ".getStr('boot_mbr')) foreach (@drives);
	this->lbBootloader->setCurrentItem(1);
    }
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
		do_system("cp $mnt/etc/lilo.conf $mnt/etc/lilo.conf.old");
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
";
		if ($kernel26 eq "1") { 
			print LILO "append=\"devfs=nomount acpi=ht nomce splash=silent\"\n"; # Use udev
		} else {
			print LILO "append=\"devfs=mount splash=silent\"\n"; # Use devfs
		}
		print LILO "vga=788
read-only
";
		# Add other partitions if installing to MBR
		if (substr($bootdev, -1) =~ /[a-z]/ ) {
			print"\nMBR extra Partitions for LILO\n";
		    foreach my $dev (sort keys %devs) {
			print "MBR - LILO - checking $dev \n";
			next if ( $devs{$dev}{media} !~ /hd/ );  # Only hard disks
			next if ( substr($dev, -1) =~ /[a-z]/);  # Skip MBR hda
			next if ( $devs{$dev}{type} =~ /swap/ ); # Skip any swap
			print "\nRootpart = $rootpart\n";
			next if ( $dev eq $rootpart );		 # Skip self - root
			next if ( $dev eq $homepart );		 # home
			next if ( $dev eq $varpart );		 # var
			next if ( $dev eq $tmppart );		 # tmp

			print "MBR - LILO - adding Partition: $dev\n";
## test for bootable partition bootflag (from lilo QuickInst) to avoid
## Fatal: First sector of /dev/hda10 doesn't have a valid boot signature
my $r = system "[ \"XY\" = \"`(dd of=/dev/null bs=510 count=1; dd bs=2 count=1 |
          tr -c '\125\252' . | tr '\125\252' XY) <$dev 2>/dev/null`\" ]" ;
				if ($r == 0) {  # We are ok to use 'other'
					my $label = substr($devs{$dev}{mount}, 5); # remove /mnt/
					print LILO "\nother=$dev
label=\"$label\"
";
				} else {
				next;
				}  ## Need to work on following code
#				print "Non boot-loader partition: $dev \n";
#				my $base = "$devs{$dev}{mount}"."/boot";
#				opendir(DIR, "$devs{$dev}{mount}"."/boot") || next; ## kernel hunt
#				my $filename;
#				   while ($filename = readdir DIR) {
#				   next if ($filename !~ 'vmlinuz-');
#			print "Filename = $filename\n";
#			my $kversion = substr($filename, 8, 25);  # strip 'vmlinuz-'
#			print "Kversion = $kversion\n";
#			#my $base = $filename;
#			#$base =~ s,.*/,, ; ## basename
#			print "Base = $base\n";
#			my $label = "$base"."-"."$kversion";
#			print "LABEL = $label\n";
#			#my $linitrd = "$dev"."/boot/initrd-$kversion".".img";
#			my $linitrd = "$base"."initrd-$kversion".".img";
#			print "Linitrd = $linitrd\n\n";
#			print LILO "\nimage=$base/$filename
#label=\"$label\"
#read-only
#initrd=$base/initrd-$kversion.img
#root=$dev
#";
#				}
#			}
		    }
		}
		close LILO;
		do_system("mount -t proc none $mnt/proc");
		if ($kernel26 eq "1") {
			do_system("cp -a /dev $mnt"); # Copy devices for udev
			do_system("mount -t none /dev $mnt/dev -o bind");
		} else {
			do_system("mount -t devfs none $mnt/dev"); # Mount for devfs
		}
		do_system2("/sbin/lilo -v -r $mnt");
		do_system("umount $mnt/dev");
		do_system("umount $mnt/proc");
	}
	Qt::MessageBox::information (this, getStr('caption'), getStr('bl_written'));
#	emit this->next(); # Jump to next page
}

sub writeFstab {
	my ($devs) = @_;

	if (!defined($debug)) {
		my @fstab = fs::read_fstab("", "/etc/fstab");
		my $hdds = {};
		fs::add2all_hds($hdds, @fstab);
		fs::write_fstab($hdds, $mnt);

		open FSTAB, '>', "$mnt/etc/fstab";
		print FSTAB "## Livecd-install ".getStr('fstab_info')."\n";
		print FSTAB "\nnone"."\t"."/proc"."\t"."proc"."\t"."defaults"."\t"."0 0";
		print FSTAB "\nnone"."\t"."/dev/pts"."\t"."devpts"."\t"."mode=0620"."\t"."0 0";

		if ($kernel26 eq "1") {   # If 2.6 kernel add these lines...
		   print "DEBUG: Added 2.6 kernel to FSTAB\n";
		   print FSTAB "\nnone"."\t"."/proc/bus/usb"."\t"."usbfs"."\t"."defaults"."\t"."0 0";
		}
                else { # 2.4 kernel
                   print FSTAB "\nnone"."\t"."/dev"."\t"."devfs"."\t"."defaults"."\t"."0 0";
		   print "DEBUG: 2.4 kernel found.\n";
		}

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
				$mount = $devs->{$dev}{mount};
				do_system2("mkdir -p $mnt/$mount 2>/dev/null");
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
			print "FSTAB: $entry \n";
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


sub diskPartition # SLOT: (  )
{
        my ($check) = @_;
        do_system("diskdrake");   # or another tool, e.g. parted
}


sub logging_yes # SLOT: ( )
{
        my ($check) = @_;
	my $message = "";
        my $result = do_system2("/bin/echo chkconfig --add syslog | chroot $mnt");
	if ($result eq "0") {
           Qt::MessageBox::information( this, getStr('caption'), getStr('logging_yes'));
        } else {
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
        }
}


sub logging_no # SLOT: ( );
{
        my ($check) = @_;
	my $message = "";
        my $result = do_system2("/bin/echo chkconfig --del syslog | chroot $mnt");
        if ($result eq "0") {
           Qt::MessageBox::information( this, getStr('caption'), getStr('logging_no'));
        } else {
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
        }
}


sub writeRootPW # SLOT: (  )
{
	my($check) = @_;
	my $result = "";
	my $message = "";
	# Get both root passwords 
	my $pw1 = lineEdit1->text();
	my $pw2 = lineEdit2->text();

	## Test - if " ' " found ->reject,  if not same ->reject, if null ->reject, if short ->warn and continue
        if (index($pw1, "'") ne '-1') {   # Reject if " ' " found
           Qt::MessageBox::warning( undef, getStr('caption'), getStr('pword_no_sq'), getStr('btn_retry'));
           return;
        }
        if ($pw1 ne $pw2) {
           Qt::MessageBox::warning( undef, getStr('caption'), getStr('pword_not_same'), getStr('btn_retry'));
	   return;
        }
        if ($pw1 eq "") {
           Qt::MessageBox::warning(undef, getStr('caption'), getStr('pword_null'), getStr('btn_retry'));
           return;
        }
	if (length($pw1)<8) {
	   Qt::MessageBox::information(this, getStr('caption'), getStr('pword_short'));
	}

	# Passwords ok - now write to disk
	$result = do_system2("/bin/echo '"."$pw1"."' | chroot $mnt /usr/bin/passwd --stdin root");
        print "\nDEBUG: Password: $result\n";
	if ($result eq "0") {	 
	   Qt::MessageBox::information( this, getStr('caption'), getStr('pword_ok'));
	} else {
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
	}
	lineEdit1->clear();
	lineEdit2->clear();
}


sub deleteGuest # SLOT: ( )
{
	my($check)  = @_;
	my $comm    = "";
	my $message = "";
	my $result  = "";

	# Delete the guest account and report - not found, deleted ok, error
	$comm="/usr/sbin/userdel -r guest";
	$result = do_system2("/bin/echo $comm | chroot $mnt");
	print "\nDEBUG: Delete Guest result = $result\n";
        if ($result eq "1536") {
	   Qt::MessageBox::information (this, getStr('caption'), getStr('guest_not_found'));
        } elsif ($result eq "0") {
           Qt::MessageBox::information (this, getStr('caption'), getStr('guest_del_ok'))
	} else { 
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
	}
}


sub createUser # SLOT: ( )
{
        my($check)  = @_;
        my $message = "";
        my $comm    = "";
        my $error   = "";
        my $result  = "";
 
        # Get inputs (realname optional)
	my $username = lineEditLogin->text();
        my $realname = lineEditReal->text();
        my $pw1      = lineEditUPW->text();
        my $pw2      = lineEditUPW2->text();

	## Validation - user/pw1/pw2 null->reject, pw1<>pw2->reject, pw short->warn and accept

	if (index($pw1, "'") ne '-1') {   # Reject if " ' " found
	   Qt::MessageBox::warning( undef, getStr('caption'), getStr('pword_no_sq'), getStr('btn_retry'));
	   return;
	}
	if ( ($username eq "") || ($pw1 eq "") || ($pw2 eq "") ) {
	   Qt::MessageBox::warning(undef, getStr('caption'), getStr('missing_value'), getStr('btn_retry'));
	   return;
	}
	if ($pw1 ne $pw2) {
	   Qt::MessageBox::warning(undef, getStr('caption') , getStr('pword_not_same'), getStr('btn_retry'));
	   return;
	}
	if ($pw1 eq "") {
	   Qt::MessageBox::warning(undef, getStr('caption'), getStr('pword_null'), getStr('btn_retry'));
	   return;
	}
	if (length($pw1)<8) {
	   Qt::MessageBox::information(undef, getStr('caption'), getStr('pword_short'));
	}
	if (index($username, "'") ne '-1') {   # Reject if " ' " found
	   Qt::MessageBox::warning( undef, getStr('caption'), getStr('pword_no_sq'), getStr('btn_retry'));
	   return;
	}
	if (index($realname, "'") ne '-1') {   # Reject if " ' " found
	   Qt::MessageBox::warning( undef, getStr('caption'), getStr('pword_no_sq'), getStr('btn_retry'));
	   return;
	}

	## Data accepted, make the user

	# Add the group
	$result = do_system2("/bin/echo groupadd '"."$username"."' | chroot $mnt");
	print "\nDEBUG add group result=$result\n";
        if (($result ne "0") && ($result ne "2304")) {
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
	   return;
        }

	# Add the user
	if ($realname eq "") {
	   $comm = "\"useradd -g '"."$username"."' -d '"."/home/$username"."' -s /bin/bash  -m -k /etc/skel -p foo '"."$username"."'\"";
	} else {
	   $comm = "\"useradd -g '"."$username"."' -d '"."/home/$username"."' -s /bin/bash -c '"."$realname"."' -m -k /etc/skel -p foo '"."$username"."'\"";
	}
	$result = do_system2("/bin/echo $comm | chroot $mnt");
	print "\nDEBUG add user result=$result\n";
	if (($result ne "0") && ($result ne "2304")) {
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
	   return;
	}
	if ($result eq "2304") {
	   $message = "update";
	}

	# Change the password
	$result = do_system2("/bin/echo '"."$pw1"."' | chroot $mnt /usr/bin/passwd --stdin '"."$username"."'");
	print "\nDEBUG: change user password result =$result\n";
        if ($result ne "0") {
           $message = getStr('function_error')."$result";
           Qt::MessageBox::information (this, getStr('caption'), $message);
	   return;
	}
	if ($message eq "update") {
	   Qt::MessageBox::information (this, getStr('caption'), getStr('pword_updated')); 
        } else {
	   $message = getStr('user')."$username".getStr('user_added');
	   Qt::MessageBox::information (this, getStr('caption'), $message);
	}
	lineEditLogin->clear();
	lineEditReal->clear();
	lineEditUPW->clear();
	lineEditUPW2->clear();
}

sub cbLanguage_act # SLOT: ( const QString & )
{
	my($check)  = @_;
	$lang = substr($check, -2);   #e.g. French - fr
	if ($lang ne 'ge') {    # Langua'ge'
		init();
	}
}

