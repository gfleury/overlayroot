#
# Makefile  
#

build:

DRACUT_OVERLAYROOT_D = dracut/modules.d/50overlayroot

install:
	mkdir -p "$(DESTDIR)/$(DRACUT_OVERLAYROOT_D)"
	for f in mount-overlayroot.sh install ; do \
		install "overlayroot/$(DRACUT_OVERLAYROOT_D)/$$f" \
			"$(DESTDIR)/$(DRACUT_OVERLAYROOT_D)/" ; \
	done

# vi: ts=4 noexpandtab syntax=make
