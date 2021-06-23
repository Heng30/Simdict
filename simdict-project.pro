TEMPLATE = subdirs

SUBDIRS = simdict xclip

simdict.file = simdict/simdict.pro
xclip.file = xclip/xclip.pro

simdict.depends = xclip
