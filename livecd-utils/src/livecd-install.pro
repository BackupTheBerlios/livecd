unix {
  UI_DIR = .ui
  MOC_DIR = .moc
  OBJECTS_DIR = .obj
}
FORMS	= livecd-install.ui
IMAGES	= ../images/left_simple.png
TEMPLATE	=app
CONFIG	+= qt warn_on release
LANGUAGE	= Perl
PROGRAM_NAME	= livecd-install.pl
MAIN_FORM	= fMain
