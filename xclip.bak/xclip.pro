TEMPLATE = lib

CONFIG += static c++11

DEFINES += HAVE_ICONV=1
#LIBS += -lXmu -lX11

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
