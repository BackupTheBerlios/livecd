unix {
  UI_DIR = .ui
  MOC_DIR = .moc
  OBJECTS_DIR = .obj
}
PROGRAM_NAME	= livecd-install.pl
MAIN_FORM	= fMain
TEMPLATE	= app
LANGUAGE	= Perl

CONFIG	+= qt warn_on release


FORMS	= livecd-install.ui
IMAGES	= ../images/left_simple.png

