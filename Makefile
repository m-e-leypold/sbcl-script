# 
# sbcl-script --- Script runner for scripts written in Steel Bank Common Lisp
# Copyright (C) 2023 M E Leypold
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

all::
install::
live-install::
.PHONY: @always

.ONESHELL:

SHORT-NAME ?= $(shell echo "$(notdir $(CURDIR))" | sed 's|_.*||')

DEST       ?= $(CURDIR)/.stage
PREFIX     ?= /usr/local
LISPDIR    ?= $(PREFIX)/share/common-lisp/source/$(SHORT-NAME)
BINDIR     ?= $(PREFIX)/bin

LISPFILES  ?= $(wildcard *.lisp *.asd)
BINFILES   ?= $(patsubst ./%,%,$(shell find . -maxdepth 1 -mindepth 1 -executable -type f))

LISPFILES   := $(strip $(LISPFILES))
BINFILES    := $(strip $(BINFILES))

USER-BINDIR   ?= $(lastword $(wildcard ~/my/scripts/bin ~/my/bin ~/bin))
USER-LISPROOT ?= $(lastword $(wildcard ~/share/common-lisp/source ~/my/asdf ~/.asdf))
USER-LISPDIR  := $(USER-LISPROOT)/$(SHORT-NAME)


$(info PREFIX       = $(PREFIX))
$(info DEST         = $(DEST))
$(info BINDIR       = $(BINDIR))
$(info LISPDIR      = $(LISPDIR))
$(info USER-BINDIR  = $(USER-BINDIR))
$(info USER-LISPDIR = $(USER-LISPDIR))

install-lisp:
	set -eu
	mkdir -p $(DEST)$(LISPDIR)
	install -m 644 $(LISPFILES) $(DEST)$(LISPDIR)

install-bin:
	set -eu
	mkdir -p $(DEST)$(BINDIR)
	install -m 755 $(BINFILES) $(DEST)$(BINDIR)/

ifneq ($(LISPFILES),)
  install:: install-lisp
endif

ifneq ($(BINFILES),)
  install:: install-bin
endif

clean::
	rm -rf $(DEST)

# * ----------------------------------------------------------

VERSION := $(shell git describe --tags)
PKGVER  := $(shell echo "$(VERSION)" | sed 's|[-]|+|g' | tr '[A-Z]' '[a-z]')
TARFILE := $(SHORT-NAME)-$(VERSION).tar.gz
PACKAGE := $(SHORT-NAME)-$(PKGVER)-1-any.pkg.tar.zst

$(info VERSION  = $(VERSION))
$(info PKGVER   = $(PKGVER))
$(info PACKAGE  = $(PACKAGE))

PKGBUILD.$(VERSION):: PKGBUILD.template
	sed <$< \
            's|__PKGVER__|$(PKGVER)|g;s|__SHORTNAME__|$(SHORT-NAME)|g;s|__VERSION__|$(VERSION)|' \
            >$@

PKGBUILD: PKGBUILD.$(VERSION)
	cp $< $@

$(TARFILE):: PKGBUILD.$(VERSION)
	git archive -o "$@" HEAD

$(PACKAGE): $(TARFILE) PKGBUILD
	rm -rf pkg src
	makepkg -f

package: $(PACKAGE)

clean::
	rm -f *.tar.gz *.zst
	rm -rf src pkg
	rm -f PKGBUILD.[0-9]* PKGBUILD *~

# * ----------------------------------------------------------

-include Project/Project.mk

Project:
	git clone -b project --single-branch . Project

# * ----------------------------------------------------------

$(info )

# * ----------------------------------------------------------
