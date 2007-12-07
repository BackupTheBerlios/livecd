%define name 	remaster_gui
%define summary 	Graphical wizard for remastering your installation
%define version 	0.3
%define release 	%mkrel 1

Summary: 	%summary
Distribution:	PCLinuxOS
Name:		%name
Version:	%version
Release:	%release
License:		GPL
Group:		System/Configuration/Other
Source:		%name-%version.tar.gz
BuildRoot:	%_tmppath/%name-%version-buildroot
Packager:	Gri6507

BuildRequires:	perl-Tk-Wizard
Requires:	perl-Tk-Wizard mklivecd

%description
This is a graphical wizard that will guide you step by step through what is at times not obvious and complicated process of performing a remaster of your installation.

%prep
%setup -q

%build

%install
install -d %{buildroot}%{_sbindir}/%{name}
for f in *
do
    install -m 750 ${f} %{buildroot}%{_sbindir}/%{name}/${f}
done

echo -e '#!/bin/sh ' > $RPM_BUILD_ROOT/%{_sbindir}/%{name}.sh
echo -e 'cd %{_sbindir}/%{name} ' >> $RPM_BUILD_ROOT/%{_sbindir}/%{name}.sh
echo -en './%{name}.pl $@' >> $RPM_BUILD_ROOT/%{_sbindir}/%{name}.sh

#Copy the icon
mkdir -p %{buildroot}/%{_datadir}/icons
cp %{_topdir}/BUILD/%{name}-%{version}/%{name}.png %{buildroot}/%{_datadir}/icons/%{name}.png

#Create the desktop entry
mkdir -p $RPM_BUILD_ROOT%{_datadir}/applications
cat > $RPM_BUILD_ROOT%{_datadir}/applications/%{name}.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Name= RemasterGUI
Comment=%{summary}
Exec=%{_sbindir}/%{name}.sh
Icon=%{name}
Terminal=false
Type=Application
StartupNotify=true
X-KDE-SubstituteUID=true
X-KDE-Username=root
Categories=System;Archiving;X-PCLinuxOS-System-Archiving-Backup;X-MandrivaLinux-System-Archiving-Backup;
EOF

desktop-file-install \
	--vendor="" \
	--dir $RPM_BUILD_ROOT%{_datadir}/applications \
	$RPM_BUILD_ROOT%{_datadir}/applications/%name.desktop

#Update menus
%post
%update_menus
%update_desktop_database

%postun
%clean_menus
%clean_desktop_database

%clean
rm -rf $RPM_BUILD_ROOT

#Install files
%files
%defattr(750,root,root,-)
%{_sbindir}/%{name}.sh
%{_sbindir}/%{name}/
%{_datadir}/applications/%{name}.desktop
%{_iconsdir}/%{name}.png

%changelog
* Wed Nov 29 2007 DidouPh <didouph@matoilnet.com> rebuilt
* Wed Nov 28 2007 Paul Grinberg <gri6507@yahoo.com> 0.3-1pclos2007
- Initial release for PCLinuxOS 2007
