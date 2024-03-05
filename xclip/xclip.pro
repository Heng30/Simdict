TEMPLATE = lib

CONFIG += static c++11

DEFINES += HAVE_ICONV=1

CONFIG(debug, debug|release) {
    TARGET = xclipd
}

CONFIG(release, debug|release) {
    TARGET = xclip
}

HEADERS += \
    xclib.h \
    xclip.h \
    xcprint.h

SOURCES += \
    xclib.c \
    xclip.c \
    xcprint.c

MOC_DIR = $$PWD/../build/$$TARGET
RCC_DIR = $$PWD/../build/$$TARGET
DESTDIR = $$PWD/../build/$$TARGET
OBJECTS_DIR = $$PWD/../build/$$TARGET
