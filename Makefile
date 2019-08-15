#
# Makefile  
#

build:

DRACUT_OVERLAYROOT_D = dracut/modules.d/50overlayroot

install:
	mkdir -p "$(BUILDROOT)/$(DESTDIR)/$(DRACUT_OVERLAYROOT_D)"
	for f in mount-overlayroot.sh module-setup.sh; do \
		install "overlayroot/$$f" \
			"$(BUILDROOT)/$(DESTDIR)/$(DRACUT_OVERLAYROOT_D)/" ; \
	done
	mkdir -p "$(BUILDROOT)/usr/sbin"
	for f in bin/*; do \
		install "$$f" \
			"$(BUILDROOT)/usr/sbin" ; \
	done
	mkdir -p "$(BUILDROOT)/etc"
	install "etc/overlayroot.conf" "$(BUILDROOT)/etc"

rpm:
	rpmbuild -ba specs/dracut-modules-overlayroot.spec

publish:
	aws s3 cp /usr/src/rpm/RPMS/noarch/dracut-modules-overlayroot-0.1-beta.amzn1.noarch.rpm s3://gfleury --acl public-read	

# vi: ts=4 noexpandtab syntax=make
