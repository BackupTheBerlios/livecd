#!/usr/bin/perl

# $Id: remaster_gui.pl,v 1.1 2007/12/12 00:49:26 didouph Exp $ 
#
# Copyright (C) 2007 - Paul Grinberg gri6507@yahoo.com
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

use strict;
use warnings;

######################################
#   User Configurable Section

my $fgcolor = "#000000";                   # background color
my $bgcolor = "#FFFFFF";                   # foreground color
my $sb_color = "#e7e7e7";                  # scroll bar and button color
my $text_font = 'helvetica 12';            # Body text font
my $title_font = 'helvetica 12 bold';      # Title text font
my $debug = 0;                             # set to 1 to enable mklivecd output to terminal

#   End User Configurable Section
######################################

setpgrp(0, 0);                                 # start a new process group so cleanup is easier
pipe(FROM_GUI, TO_WORKER) or die "pipe: $!\n"; # open communication one way
pipe(FROM_WORKER, TO_GUI) or die "pipe: $!\n"; # open communication the other way
select((select(TO_WORKER), $|=1)[0]);          # autoflush those pipes
select((select(TO_GUI), $|=1)[0]);

my $worker_pid;
if ($worker_pid = fork) {                      # fire off a worker thread, so GUI is still responsive
    close FROM_GUI; close TO_GUI;              # clean up unneeded communication pipes
} else {
    die "cannot fork worker: $!\n" unless defined $worker_pid;
    close FROM_WORKER; close TO_WORKER;
    do_work();                                 # worker process will sit idle until it's told to start
}

use File::Path;
use File::Basename;
use Tk::Wizard qw(MainLoop);
require Tk::LabFrame;
require Tk::LabEntry;
require Tk::BrowseEntry;
require Tk::ProgressBar;

my @keyboards = qw(US AL ARA AM AZ BD BY BE BT BA BR BG CA HR CZ DK EE FO FI FR GE DE GR HU IS IN IR IE IL IT JP KG LA LATAM LV LT MKD MT MAO MN MM NL NO PK NEC_VNDR/JP PL PT RO RU SPR SK SI ES LK SE CH SY TJ TH TR UA GB US UZ VN);
my @resolutions = qw(800x600 1024x768 1280x1024);
my $VERSION = 0.3;
my %opt;
my %gui;
my @viewed_pages;
$|++;

my $wizard = new Tk::Wizard(-title=>"PCLOS LiveCD Remaster GUI", -imagepath=>'remaster_logo.gif', -topimagepath=>'logo_sm.gif');

$wizard->protocol('WM_DELETE_WINDOW',\&exit_cleanly);
$wizard->optionAdd("*background", $bgcolor);
$wizard->optionAdd("*foreground", $fgcolor);
$wizard->optionAdd("*rotext*font", $text_font);
$wizard->optionAdd("*entry*font", $text_font);

$wizard->addPage( sub{page_splash($wizard)});
$wizard->addPage( sub{page_remaster_opt($wizard)});
$wizard->addPage( sub{page_bootopts_1($wizard)});
$wizard->addPage( sub{page_bootopts_2($wizard)});
$wizard->addPage( sub{page_image_generation_1($wizard)});
$wizard->addPage( sub{page_image_generation_2($wizard)});
$wizard->addPage( sub{page_confirm($wizard)});
$wizard->addPage( sub{page_progress($wizard)});
$wizard->addPage( sub{page_finish($wizard)});
$wizard->Show;
MainLoop;

sub page_splash {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'PCLinuxOS LiveCD Remaster GUI', -font=>$title_font);

    my $t = $p->ROText(-height=>3, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
    $t->insert('end','Graphical utility to assist in remastering your Linux installation. Remastering is useful as both a means to back up your entire installation (both programs and data), as well as a means of easily redistributing your specific installation of the OS, programs, and data to other computers. All default settings in this Wizard have been caregfully chosen, so if you are not sure about some setting for any option, just leave it at its default value.');

    return $p;
}

sub page_remaster_opt {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'PCLinuxOS LiveCD Remaster GUI', -font=>$title_font);

    if (!defined($viewed_pages[0])) {
        $viewed_pages[0] = 1;
        $opt{workdir} = '/root/temp/livecd';
        $opt{outputdir} = '/root/livecd_iso';
        $opt{livecd_name} = "$opt{outputdir}/livecd.iso";
    }

    my $f_opt = $p->LabFrame(-label=>'Basic Remaster Options', -labelside=>"acrosstop")->pack(-side=>'top', -fill=>'both', -expand=>1);
    {
        my $t = $f_opt->ROText(-height=>6, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
        $t->insert('end','The working directory is the place where the LiveCD gets assembled from pieces. It needs to be big enough to contain the full uncompressed remaster. The output directory is the place where the final LiveCD image will be placed. It needs to be big enough to hold the compressed image. Together the two directories need to be 1.3 times the size of the system being remastered (allowing for exclusions nodir & nofile).');
        my $f_w = $f_opt->Frame()->pack(-side=>'top', -expand=>1, -fill=>'x');
        {
            $f_w->LabEntry(-label=>'Work Dir:', -labelPack=>[qw(-side left -anchor w)], -width=>15, -textvariable=>\$opt{workdir})->pack(-side=>'left', -expand=>1, -fill=>'x');
            my $folder = $f_w->Photo(-file=>'folder.gif');
            $f_w->Button(-image=>$folder, -command=>sub {
                $opt{workdir}= $f_w->chooseDirectory(-initialdir=>Cwd::cwd(), -title=>"Choose Work Directory");
            })->pack(-side=>'left');
        }
        my $f_o = $f_opt->Frame()->pack(-side=>'top', -expand=>1, -fill=>'x');
        {
            $f_o->LabEntry(-label=>'LiveCD Path and Name:', -labelPack=>[qw(-side left -anchor w)], -width=>15, -textvariable=>\$opt{livecd_name})->pack(-side=>'left', -expand=>1, -fill=>'x');
            my $folder = $f_o->Photo(-file=>'folder.gif');
            $f_o->Button(-image=>$folder, -command=>sub {
                $opt{livecd_name} = $f_o->getSaveFile(-initialdir=>$opt{outputdir}, -title=>"Choose LiveCD Path and Name");
            })->pack(-side=>'left');
        }
    }

    $$wizard{Configure}{-preNextButtonAction} = sub {
        `rm -rf $opt{workdir}`;       # prepare a clean build environment
        eval {mkpath([$opt{workdir}], 0, 0700)};
        if ($@) {
            $wizard->parent->messageBox(-icon=>'error',
                                        -title=>'Oops',
                                        -text=>"Error creating $opt{workdir}.");
            return 0;
        }
        my($dummy, $output_dir, $dummy2) = fileparse($opt{livecd_name});
        unless (-d $output_dir) {
            eval {mkpath([$output_dir], 0, 0700)};
            if ($@) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"Error creating $opt{outputdir}.");
                return 0;
            }
        }
        return 1;
    };
    return $p;
}

sub page_bootopts_1 {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'Select LiveCD Boot Options (1 of 2)', -font=>$title_font);

    if (!defined($viewed_pages[1])) {
        $viewed_pages[1] = 1;
        $opt{bootloader} = 'grub';
        $opt{bootmsg_enable} = 0;
        $opt{bootkey} = "F2";
    }

    my $f_bootloader = $p->LabFrame(-label=>'Bootloader Main Options', -labelside=>"acrosstop")->pack(-side=>'top', -fill=>'both', -expand=>1);
    {
        my $t = $f_bootloader->ROText(-height=>2, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
        $t->insert('end','Select the bootloader to use on the livecd i.e. isolinux, GRUB or syslinux for usb stick.');
        my $f = $f_bootloader->Frame()->pack(-side=>'left', -fill=>'x', -expand=>1);
        {
            $f->Radiobutton(-text=>'iso', -value=>'iso', -variable=>\$opt{bootloader}, -activebackground=>$bgcolor, -highlightthickness=>0)->pack(-side=>'left', -expand=>1);
            $f->Radiobutton(-text=>'grub',-value=>'grub',-variable=>\$opt{bootloader}, -activebackground=>$bgcolor, -highlightthickness=>0)->pack(-side=>'left', -expand=>1);
            $f->Radiobutton(-text=>'usb', -value=>'usb', -variable=>\$opt{bootloader}, -activebackground=>$bgcolor, -highlightthickness=>0)->pack(-side=>'left', -expand=>1);
        }
    }
    
    my $f_bootmsg = $p->LabFrame(-label=>'Boot Message Options', -labelside=>"acrosstop")->pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>'1');
    {
        my $t = $f_bootmsg->ROText(-height=>4, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'x');
        $t->insert('end','Decide if you want to display a special message at the boot prompt. If so, then enable this feature, choose the file containing the message, and define the key binding for displaying the message.');
        my $f = $f_bootmsg->Frame()->pack(-side=>'left', -expand=>1, -fill=>'both');
        {
            my @dependants;
            $f->Checkbutton(-text=>'Enable', -variable=>\$opt{bootmsg_enable}, -onvalue=>1,  -offvalue=>0, -padx=>15, -activebackground=>$bgcolor, -highlightthickness=>0, -command=> sub {
                foreach(@dependants) {
                    $_->configure(-state=>$opt{bootmsg_enable} ? 'normal' : 'disabled');
                }
            })->pack(-side=>'left');
            
            my $q = $f->Frame()->pack(-side=>'right', -expand=>1, -fill=>'both');
            {
                my $q_left = $f->Frame(-padx=>5)->pack(-side=>'right', -expand=>1, -fill=>'x');
                {
                    my $msg_key = $q_left->BrowseEntry(-label=>'Msg Key:', -width=>2, -variable=>\$opt{bootkey}, -state=>$opt{bootmsg_enable} ? 'normal' : 'disabled')->pack(-side=>'left', -expand=>1, -fill=>'x');
                    $msg_key->insert('end', "F$_") for (1 .. 12);
                    push @dependants, $msg_key;
                }
                my $q_right = $f->Frame(-padx=>5)->pack(-side=>'right', -expand=>1, -fill=>'both');
                {
                    push @dependants, $q_right->LabEntry(-label=>'Msg File:', -labelPack=>[qw(-side left -anchor w)], -width=>15, -textvariable=>\$opt{bootmsg}, -state=>$opt{bootmsg_enable} ? 'normal' : 'disabled')->pack(-side=>'left', -expand=>1, -fill=>'x');
                    my $folder = $q_right->Photo(-file=>'folder.gif');
                    push @dependants, $q_right->Button(-image=>$folder, -state=>$opt{bootmsg_enable} ? 'normal' : 'disabled', -command=> sub {
                        $opt{bootmsg} = $q_right->getOpenFile(-initialdir=>Cwd::cwd(), -title=>"Choose Msg File");
                    })->pack(-side=>'left');
                }
            }
        }
    }
    $$wizard{Configure}{-preNextButtonAction} = sub {
        if ($opt{bootmsg_enable}) {
            unless (defined($opt{bootmsg})) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"Please choose a Message file.");
                return 0
            }
            unless (-f $opt{bootmsg}) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"'$opt{bootmsg}' does not appear to be a valid file. Please choose a valid Message file.");
                return 0
            }
        }
        return 1
    };
    return $p;
}

sub page_bootopts_2 {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'Select LiveCD Boot Options (2 of 2)', -font=>$title_font);

    if (!defined($viewed_pages[2])) {
        $viewed_pages[2] = 1;
        $opt{bootimg_enable} = 0;
        $opt{resolution} = '1024x768';
        $opt{keyboard} = 'US';
        $opt{timeout} = 15;
        $opt{splash} = 'silent';
        $opt{fstab} = 'rw,noauto';
    }
    
    my $f_bootloader_img = $p->LabFrame(-label=>'Bootloader Image',  -labelside=>"acrosstop")->pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>'1');
    {
        my $t = $f_bootloader_img->ROText(-height=>3, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'x');
        $t->insert('end','Decide if you want to use a picture for a boot image. If so, then enable this feature and choose the file containing the RLE format picture.');
        my $f = $f_bootloader_img->Frame()->pack(-side=>'top', -expand=>1, -fill=>'both');
        {
            my @dependants;
            $f->Checkbutton(-text=>'Picture Enable', -activebackground=>$bgcolor, -highlightthickness=>0,  -variable=>\$opt{bootimg_enable}, -onvalue=>1,  -offvalue=>0, -padx=>15, -command=> sub {
                    foreach(@dependants) {
                        $_->configure(-state=>$opt{bootimg_enable} ? 'normal' : 'disabled');
                    }
            })->pack(-side=>'left');
            my $q = $f->Frame()->pack(-side=>'right', -expand=>1, -fill=>'both');
            {
                push @dependants, $q->LabEntry(-label=>'Image File:', -labelPack=>[qw(-side left -anchor w)], -width=>15, -textvariable=>\$opt{bootimg}, -state=>$opt{bootimg_enable} ? 'normal' : 'disabled')->pack(-side=>'left', -expand=>1, -fill=>'x');
                my $folder = $q->Photo(-file=>'folder.gif');
                push @dependants, $q->Button(-image=>$folder, -state=>$opt{bootimg_enable} ? 'normal' : 'disabled', -command=> sub {
                        $opt{bootimg} = $q->getOpenFile(-initialdir=>Cwd::cwd(), -title=>"Choose Image file");
                })->pack(-side=>'left');
            }
        }
    }
    my $f_bootloader_adv = $p->LabFrame(-label=>'Bootloader Advanced Options',   -labelside=>"acrosstop")->pack(-side=>'bottom', -anchor=>'sw', -fill=>'both', -expand=>'1');
    {
        my $f1 = $f_bootloader_adv->Frame()->pack(-side=>'top', -expand=>1, -fill=>'both');
        {
            my @sorted_keyboards = sort @keyboards;
            $f1->BrowseEntry(-label=>'Keyboard:', -width=>4, -variable=>\$opt{keyboard}, -choices=>\@sorted_keyboards)->pack(-side=>'left', -expand=>1, -fill=>'x');
            $f1->BrowseEntry(-label=>'Resolution:', -width=>9, -variable=>\$opt{resolution}, -choices=>\@resolutions)->pack(-side=>'left', -expand=>1, -fill=>'x');
            $f1->LabEntry(-label=>'Timeout:', -labelPack=>[qw(-side left -anchor w)], -width=>3, -textvariable=>\$opt{timeout})->pack(-side=>'left', -expand=>1, -fill=>'x');
            $f1->BrowseEntry(-label=>'Splash:', -width=>7, -variable=>\$opt{splash}, -choices=>[qw(silent verbose no)])->pack(-side=>'left', -expand=>1, -fill=>'x');
        }
        my $f2 = $f_bootloader_adv->Frame(-background=>$bgcolor)->pack(-side=>'bottom', -expand=>1, -fill=>'x');
        {
            $f2->LabEntry(-label=>'Extra Boot Options:', -labelPack=>[qw(-side left -anchor w)], -width=>20, -textvariable=>\$opt{bootopt})->pack(-side=>'left', -expand=>1, -fill=>'x');
            $f2->LabEntry(-label=>'Fstab Options:', -labelPack=>[qw(-side left -anchor w)], -width=>20, -textvariable=>\$opt{fstab})->pack(-side=>'left', -expand=>1, -fill=>'x');
        }
    }
    $$wizard{Configure}{-preNextButtonAction} = sub {
        if ($opt{bootimg_enable}) {
            unless (defined($opt{bootimg})) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"Please choose a Boot Image file.");
                return 0
            }
            unless (-f $opt{bootimg}) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"'$opt{bootimg}' does not appear to be a valid file. Please choose a valid Boot Image file.");
                return 0
            }
        }
        return 1
    };
    return $p;
}

sub page_image_generation_1 {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'Select LiveCD Image Generation Options (1 of 2)', -font=>$title_font);

    if (!defined($viewed_pages[3])) {
        $viewed_pages[3] = 1;
        $opt{root} = '/';
        $opt{tmp} = '/tmp';
        my $kernel = `uname -r`;
        chomp $kernel;
        $opt{kernel} = $kernel;
        $opt{sort_enable} = 0;
        $opt{md5sum} = 1;
        $opt{looptype} = 'sqfs';
    }
    
    my $f_img_gen = $p->LabFrame(-label=>'Image Generation Options', -background=>$bgcolor,  -labelside=>"acrosstop")->pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>'1');
    {
        my $t = $f_img_gen->ROText(-height=>6, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'x');
        $t->insert('end','Choose the root directory of the live filesystem to use on the image of the LiveCD. Choose the tmp dir for the whole mklivecd process (this is not the work directory). Also, select which kernel you want on the LiveCD. If you want to sort the files on the compressed iso image according to the mkisofs-style sort specifier, then define a sort file as well.');
        my $f1 = $f_img_gen->Frame()->pack(-side=>'top', -expand=>1, -fill=>'x');
        {
            $f1->LabEntry(-label=>'Root:', -labelPack=>[qw(-side left -anchor w)], -width=>5, -textvariable=>\$opt{root})->pack(-side=>'left', -expand=>1, -fill=>'x');
            $f1->LabEntry(-label=>'Temp:', -labelPack=>[qw(-side left -anchor w)], -width=>3, -textvariable=>\$opt{tmp})->pack(-side=>'left', -expand=>1, -fill=>'x');
            my $b = $f1->BrowseEntry(-label=>'Kernel:', -width=>30, -variable=>\$opt{kernel})->pack(-side=>'left', -expand=>1, -fill=>'x');
            foreach (</boot/vmlinuz-*>) {
                my ($dummy, $kernel) = split(/vmlinuz-/);
                $b->insert('end', $kernel);
            }
        }
        my $f2 = $f_img_gen->Frame()->pack(-side=>'top', -expand=>1, -fill=>'x');
        {
            my @dependants;
            $f2->Checkbutton(-text=>'MD5', -activebackground=>$bgcolor, -highlightthickness=>0,  -variable=>\$opt{md5sum}, -onvalue=>1,  -offvalue=>0)->pack(-side=>'left');
            $f2->Checkbutton(-text=>'Sort Enable', -activebackground=>$bgcolor, -highlightthickness=>0,  -variable=>\$opt{sort_enable}, -onvalue=>1,  -offvalue=>0, -padx=>10, -command=> sub {
                    foreach(@dependants) {
                        $_->configure(-state=>$opt{sort_enable} ? 'normal' : 'disabled');
                    }
            })->pack(-side=>'left');
            my $q = $f2->Frame()->pack(-side=>'left', -expand=>1, -fill=>'both');
            {
                push @dependants, $q->LabEntry(-label=>'Sort File:', -labelPack=>[qw(-side left -anchor w)], -width=>15, -textvariable=>\$opt{sort}, -state=>$opt{sort_enable} ? 'normal' : 'disabled')->pack(-side=>'left', -expand=>1, -fill=>'x');
                my $folder = $q->Photo(-file=>'folder.gif');
                push @dependants, $q->Button(-image=>$folder, -state=>$opt{sort_enable} ? 'normal' : 'disabled', -command=> sub {
                        $opt{sort} = $q->getOpenFile(-initialdir=>Cwd::cwd(), -title=>"Choose Sort Description  File");
                })->pack(-side=>'left');
            }
            $f2->BrowseEntry(-label=>'Looptype:', -width=>7, -variable=>\$opt{looptype}, -choices=>[qw(clp sqfs iso ziso)])->pack(-side=>'left', -expand=>1, -fill=>'x');
        }
    }
    $$wizard{Configure}{-preNextButtonAction} = sub {
        if ($opt{sort_enable}) {
            unless (defined($opt{sort})) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"Please choose a Sort definition file.");
                return 0
            }
            unless (-f $opt{sort}) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"'$opt{sort}' does not appear to be a valid file. Please choose a valid Sort description file.");
                return 0
            }
        }
        return 1
    };
    return $p;
}

sub page_image_generation_2 {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'Select LiveCD Image Generation Options (2 of 2)', -font=>$title_font);

    if (!defined($viewed_pages[4])) {
        $viewed_pages[4] = 1;
        push @{$opt{nodir}}, qw(/proc/asound
                                /root/temp
                                /root/tmp
                                /mnt
                                /tmp
                                /root/temp/livecd
                                /root/livecd_iso);
        push @{$opt{nofile}},qw(/etc/fstab
                                /etc/X11/xorg.conf
                                /etc/X11/XF86Config
                                /etc/lilo.conf
                                /etc/modprobe.conf
                                /etc/modprobe.preload
                                /etc/asound.state
                                /boot/grub/menu.lst);
    }
    my $list_d;
    my $list_f;
 
    my $f_img_cont = $p->LabFrame(-label=>'Image Content Options', -background=>$bgcolor,  -labelside=>"acrosstop")->pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>'1');
    {
        my $t = $f_img_cont->ROText(-height=>3, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
        $t->insert('end','The LiveCD image will contain everything on your harddrive except for the explicitly defined files and directories. Define these exclusions below.');
        my $f1 = $f_img_cont->Frame()->pack(-side=>'top', -expand=>1, -fill=>'both');
        {
            my $f_dir = $f1->LabFrame(-label=>'Excluded Directories', -labelside=>'acrosstop')->pack(-side=>'left', -expand=>1, -fill=>'both');
            {
                my $f_l = $f_dir->Frame()->pack(-side=>'bottom', -expand=>'1', -fill=>'both');
                {
                    $list_d = $f_l->Scrolled('Text', -scrollbars=>'se', -height=>4, -width=>10, wrap=>'none')->pack(-expand=>1, -fill=>'both');
                    $list_d->Subwidget('xscrollbar')->configure(-background=>$sb_color, -activebackground=>$sb_color);
                    $list_d->Subwidget('yscrollbar')->configure(-background=>$sb_color, -activebackground=>$sb_color);
                    $list_d->insert('end', "$_\n") foreach(@{$opt{nodir}});
                }
                my $f_f = $f_dir->Frame()->pack(-side=>'bottom', -expand=>'1', -fill=>'x');
                {
                    my $exclude;
                    my $entry = $f_f->Entry(-width=>15, -textvariable=>\$exclude)->pack(-side=>'left', -expand=>1, -fill=>'x');
                    my $folder = $f_f->Photo(-file=>'folder.gif');
                    $f_f->Button(-image=>$folder, -command=>sub {
                        $exclude = $f_f->chooseDirectory(-initialdir=>Cwd::cwd(), -title=>"Choose Directory to Exclude");
                    })->pack(-side=>'left');
                    my $button = $f_f->Button(-text=>'Add', -background=>$sb_color, -command=>sub{
                        return if (!defined $exclude || $exclude eq '');
                        $list_d->insert('end',"$exclude\n");
                        $list_d->yviewMoveto(1);
                        $exclude = '';
                    })->pack(-side=>'left');
                    $entry->bind('<Return>', sub{$button->invoke});
                }
            }
            my $f_file = $f1->LabFrame(-label=>'Excluded Files', -labelside=>'acrosstop')->pack(-side=>'right', -expand=>1, -fill=>'both');
            {
                my $f_l = $f_file->Frame()->pack(-side=>'bottom', -expand=>'1', -fill=>'both');
                {
                    $list_f = $f_l->Scrolled('Text', -scrollbars=>'se', -height=>4, -width=>10, wrap=>'none')->pack(-expand=>1, -fill=>'both');
                    $list_f->Subwidget('xscrollbar')->configure(-background=>$sb_color, -activebackground=>$sb_color);
                    $list_f->Subwidget('yscrollbar')->configure(-background=>$sb_color, -activebackground=>$sb_color);
                    $list_f->insert('end', "$_\n") foreach(@{$opt{nofile}});
                }
                my $f_f = $f_file->Frame()->pack(-side=>'bottom', -expand=>'1', -fill=>'x');
                {
                    my $exclude;
                    my $entry = $f_f->Entry(-width=>15, -textvariable=>\$exclude)->pack(-side=>'left', -expand=>1, -fill=>'x');
                    my $folder = $f_f->Photo(-file=>'folder.gif');
                    $f_f->Button(-image=>$folder, -command=>sub {
                        $exclude = $f_f->getOpenFile(-initialdir=>Cwd::cwd(), -title=>"Choose File to Exclude");
                    })->pack(-side=>'left');
                    my $button = $f_f->Button(-text=>'Add', -background=>$sb_color, -command=>sub{
                        return if (!defined $exclude || $exclude eq '');
                        $list_f->insert('end',"$exclude\n");
                        $list_f->yviewMoveto(1);
                        $exclude = '';
                    })->pack(-side=>'left');
                    $entry->bind('<Return>', sub{$button->invoke});
                }
            }
        }
    }
    $$wizard{Configure}{-preNextButtonAction} = sub {
        @{$opt{nodir}}  = split(/\n/, $list_d->get('1.0','end'));
        @{$opt{nofile}} = split(/\n/, $list_f->get('1.0','end'));
    };
    return $p;
}

sub page_confirm { 
    my $wizard = shift;

    $opt{command} = "mklivecd $opt{livecd_name} --workdir $opt{workdir} --root $opt{root} --tmp $opt{tmp} --kernel $opt{kernel} --looptype $opt{looptype} --bootloader $opt{bootloader} --timeout $opt{timeout} --keyboard $opt{keyboard} --resolution $opt{resolution} --splash $opt{splash} --fstab $opt{fstab}";
    $opt{command} .= " --md5sum" if $opt{md5sum};
    $opt{command} .= " --sort $opt{sort}" if $opt{sort_enable};
    $opt{command} .= " --bootopt $opt{bootopt}" unless (!defined $opt{bootopt} || $opt{bootopt} eq '');
    $opt{command} .= " --bootmsg $opt{bootmsg} --bootkey $opt{bootkey}" if $opt{bootmsg_enable};
    $opt{command} .= " --bootimg $opt{bootimg}" if $opt{bootimg_enable};
    $opt{command} .= " --nodir " . join(',',@{$opt{nodir}}) if (scalar(@{$opt{nodir}}));
    $opt{command} .= " --nofile " . join(',',@{$opt{nofile}}) if (scalar(@{$opt{nofile}}));

    my $p = $wizard->blank_frame(-title=>'Confirm LiveCD Generation', -font=>$title_font);
    
    my $f_o = $p->Frame()->pack(-side=>'top', -expand=>1, -fill=>'both');
    {
        my $t = $f_o->ROText(-height=>4, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
        $t->insert('end',"Please review the command which results from your chosen options. When ready to start LiveCD creation, click the Next button.\n\n$opt{command}");
    }
    return $p;
}

sub page_progress {
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title => 'mklivecd Progress', -subtitle => 'This will take a while ...', -font=>$title_font);
    my $f = $p->Frame()->pack(-side=>'top', -expand=>1, -fill=>'x');
    {
        $gui{time_label} = $f->Label(-text=>'Total Elapsed Time:')->pack(-side=>'top');
        my $f_p = $f->Frame()->pack(-side=>'bottom', -expand=>1, -fill=>'x');
        {
            $f_p->Label(-text=>'Section Progress: ')->pack(-side=>'left');
            $gui{bar} = $f_p->ProgressBar(-borderwidth=>1, -relief=>'sunken', -height=>5, -blocks=>100, -colors=>[0=>'#0000FF'], -gap=>0)->pack(-side=>'left', -fill=>'x', -expand=>1);
        }
    }
    my $f2 = $p->Frame()->pack(-side=>'bottom', -expand=>1, -fill=>'both');
    {
        $gui{text} = $f2->Scrolled('ROText', -scrollbars=>'ose', -height=>6, -width=>10, wrap=>'none', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
    }

    $wizard->{backButton}->configure(-state=>'disable');
    $wizard->{nextButton}->configure(-state=>'disable');
    $wizard->fileevent(\*FROM_WORKER, 'readable'=>sub {postProgress()});
    $gui{time} = 0;
    $gui{time_after} = $wizard->repeat(1000, sub {
        my $t = $gui{time}++;
        my $s = $t % 60;
        $t -= $s;
        my $m = ($t % (60*60)) / 60;
        $t -= $m*60;
        my $h = int($t/60*60);
        my $pretty = sprintf("%d:%02d:%02d", $h, $m, $s);
        $gui{time_label}->configure(-text=>"Total Elapsed Time: $pretty");
    });
    print TO_WORKER "$opt{command}\n";  # Kick off the worker process
    return $p;
}

sub page_finish { 
    my $wizard = shift;
    my $p = $wizard->blank_frame(-title=>'LiveCD Remaster Complete', -font=>$title_font);

    my $f_o = $p->Frame()->pack(-side=>'top', -expand=>1, -fill=>'both');
    {
        my $remaster;
        my $t = $f_o->ROText(-height=>4, -borderwidth=>0, -relief=>'flat', -wrap=>'word', highlightthickness=>0, selectborderwidth=>0)->pack(-side=>'top', -expand=>1, -fill=>'both');
        $t->insert('end',"The remaster process is now complete. If everything went well, you will find your remaster image in '$opt{livecd_name}'. If you'd like to save your current remaster settings to a script for reuse some time later, do so below.");
        my $entry = $f_o->LabEntry(-label=>'Save Remaster Script:', -labelPack=>[qw(-side left -anchor w)], -width=>15, -textvariable=>\$remaster)->pack(-side=>'left', -expand=>1, -fill=>'x');
        my $folder = $f_o->Photo(-file=>'folder.gif');
        $f_o->Button(-image=>$folder, -command=>sub {
            $remaster = $f_o->getSaveFile(-initialdir=>Cwd::cwd(), -title=>"Save File As");
        })->pack(-side=>'left');
        my $button = $f_o->Button(-text=>'Save', -background=>$sb_color)->pack(-side=>'left');
        $button->configure(-command=>sub{
            return if (!defined $remaster || $remaster eq '');
            if (!open(FIL,">$remaster")) {
                $wizard->parent->messageBox(-icon=>'error',
                                            -title=>'Oops',
                                            -text=>"Error writing $remaster.");
                return 0;
            }
            print FIL "#!/bin/sh -e\n\n";
            print FIL "# Generated by PCLOS Remaster GUI v$VERSION\n";
            print FIL "$opt{command}\n";
            close(FIL);
            $button->configure(-text=>'Saved', -state=>'disabled');
        });
        $entry->bind('<Return>', sub{$button->invoke});
    }
    return $p;
}

# this routine only gets called by the GUI process.
# its sole purpose is to update the Progress Page of the wizard
# and trigger the reactivation of Next button upon completion
# and stops the timer.
sub postProgress {
    my $line = <FROM_WORKER>;
    chomp $line;
    if ($line =~ /([0-9.]*)%/) {
        $gui{bar}->value($1);
        $gui{bar}->update;
    } else {
        return if (!defined($line) || $line eq '');
        $line =~ s/://;
        if ($gui{text}->get('0.0', 'end') eq "\n") {
            $gui{text}->insert('end',"$line");
        } else {
            $gui{text}->insert('end'," ... done\n$line");
        }
        $gui{text}->yviewMoveto(1);
        if ($line =~ /Finished MKLIVECD/) {
            $wizard->{nextButton}->configure(-state=>'normal');
            $wizard->afterCancel($gui{time_after});
            $wizard->fileevent(\*FROM_WORKER, 'readable'=>'');
        } else {
            $gui{bar}->value(0);
            $gui{bar}->update;
        }
    }
}

# this subroutine only gets called by the worker process.
# its sole purpose is to get the mklivecd command from the GUI
# start the mklivecd process and pipe that output through a
# filter and back to the GUI.
sub do_work {
    my $line = <FROM_GUI>;
    exit if (!defined($line) || $line eq '');
    chomp $line;
    open MKLIVECD, "$line |" or die "Can't fork to start command: $!\n";
    while(<MKLIVECD>) {
        print if $debug;
        chomp;
        print TO_GUI "$1\n" if (/G?([a-zA-Z ]*5?[a-zA-Z ]+:)/); # Get the section headings
        print TO_GUI "$1\n" if (/([0-9.]*%)/);                  # Get the section percentages
    }
    close MKLIVECD;
    print TO_GUI "Finished MKLIVECD\n";
    exit;
}

sub exit_cleanly {
    kill 'KILL', -$$;
    waitpid($worker_pid, 0);
    `pkill mksquashfs`;       # for some reason this process does not die nicely
}
