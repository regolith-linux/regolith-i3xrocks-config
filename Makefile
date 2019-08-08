INSTALL = install
DESTDIR ?= /
PREFIX  ?= $(DESTDIR)

TARGET = $(PREFIX)/usr/share/i3xrocks

all:
	@echo "Nothing to do"

install:
	$(INSTALL) -m0644 -D i3xrocks.conf $(TARGET)/i3xrocks.conf
	$(INSTALL) -m0755 -D scripts/bandwidth $(TARGET)/bandwidth
	$(INSTALL) -m0755 -D scripts/battery $(TARGET)/battery
	$(INSTALL) -m0755 -D scripts/cpu_usage $(TARGET)/cpu_usage
	$(INSTALL) -m0755 -D scripts/disk $(TARGET)/disk
	$(INSTALL) -m0755 -D scripts/iface $(TARGET)/iface
	$(INSTALL) -m0755 -D scripts/keyindicator $(TARGET)/keyindicator
	$(INSTALL) -m0755 -D scripts/load_average $(TARGET)/load_average
	$(INSTALL) -m0755 -D scripts/mediaplayer $(TARGET)/mediaplayer
	$(INSTALL) -m0755 -D scripts/memory $(TARGET)/memory
	$(INSTALL) -m0755 -D scripts/openvpn $(TARGET)/openvpn
	$(INSTALL) -m0755 -D scripts/temperature $(TARGET)/temperature
	$(INSTALL) -m0755 -D scripts/time $(TARGET)/time
	$(INSTALL) -m0755 -D scripts/volume $(TARGET)/volume
	$(INSTALL) -m0755 -D scripts/wifi $(TARGET)/wifi

uninstall:
	rm -Rf $(PREFIX)/usr/share/i3xrocks

.PHONY: all install uninstall
