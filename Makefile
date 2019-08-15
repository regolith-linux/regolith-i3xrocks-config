INSTALL = install
DESTDIR ?= /
PREFIX  ?= $(DESTDIR)

CONF_TARGET = $(PREFIX)/etc/regolith/i3xrocks
SCRIPT_TARGET = $(PREFIX)/usr/share/i3xrocks

all:
	@echo "Nothing to do"

install:
	$(INSTALL) -m0644 -D i3xrocks.conf $(CONF_TARGET)/config
	$(INSTALL) -m0755 -D scripts/bandwidth $(SCRIPT_TARGET)/bandwidth
	$(INSTALL) -m0755 -D scripts/battery $(SCRIPT_TARGET)/battery
	$(INSTALL) -m0755 -D scripts/cpu_usage $(SCRIPT_TARGET)/cpu_usage
	$(INSTALL) -m0755 -D scripts/disk $(SCRIPT_TARGET)/disk
	$(INSTALL) -m0755 -D scripts/iface $(SCRIPT_TARGET)/iface
	$(INSTALL) -m0755 -D scripts/keyindicator $(SCRIPT_TARGET)/keyindicator
	$(INSTALL) -m0755 -D scripts/load_average $(SCRIPT_TARGET)/load_average
	$(INSTALL) -m0755 -D scripts/mediaplayer $(SCRIPT_TARGET)/mediaplayer
	$(INSTALL) -m0755 -D scripts/memory $(SCRIPT_TARGET)/memory
	$(INSTALL) -m0755 -D scripts/openvpn $(SCRIPT_TARGET)/openvpn
	$(INSTALL) -m0755 -D scripts/temperature $(SCRIPT_TARGET)/temperature
	$(INSTALL) -m0755 -D scripts/time $(SCRIPT_TARGET)/time
	$(INSTALL) -m0755 -D scripts/volume $(SCRIPT_TARGET)/volume
	$(INSTALL) -m0755 -D scripts/wifi $(SCRIPT_TARGET)/wifi

uninstall:
	rm -Rf $(SCRIPT_TARGET) $(CONF_TARGET)

.PHONY: all install uninstall
