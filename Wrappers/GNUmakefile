#
#  Copyright (C) 2000 Free Software Foundation, Inc.
#
#  Written by: Nicola Pero <nicola@brainstorm.co.uk>
#
#  This file is part of the GNUstep Java Interface Library.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; if not, write to the Free
#  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
#

#
# This file is needed only because we are building wrappers for the base 
# library separated from the base library itself
#

include $(GNUSTEP_MAKEFILES)/common.make

export GNUSTEP_INSTALLATION_DIR=$(GNUSTEP_SYSTEM_ROOT)

.PHONY: all base gui libFoundation \
        install install-base install-gui install-libFoundation \
        clean clean-base clean-gui clean-libFoundation \
        distclean distclean-base distclean-gui distclean-libFoundation

JAVA_WRAPPER_DIR=JavaWrapper

ifeq ($(debug),yes)
  JAVA_WRAPPER_DIR=JavaWrapper_debug
endif
#
# compiling
#
ifeq ($(FOUNDATION_LIB),fd)
all: libFoundation
install: install-libFoundation
clean: clean-libFoundation
distclean: distclean-libFoundation
else
all: base
install: install-base
clean: clean-base clean-gui
distclean: distclean-base distclean-gui
endif

base:
	cd base && $(MAKE)
libFoundation:
	cd libFoundation && $(MAKE)
gui:
	cd gui  && $(MAKE)

#
# install
#
install-base:
	cd base/$(JAVA_WRAPPER_DIR) && $(MAKE) install
install-libFoundation:
	cd libFoundation/$(JAVA_WRAPPER_DIR) && $(MAKE) install
install-gui:
	cd gui/$(JAVA_WRAPPER_DIR)  && $(MAKE) install

#
# clean
#
clean-base: 
	cd base             && $(MAKE) clean
clean-libFoundation: 
	cd libFoundation    && $(MAKE) clean
clean-gui:
	cd gui              && $(MAKE) clean

#
# distclean
#
distclean-base:
	cd base             && $(MAKE) distclean
distclean-libFoundation:
	cd libFoundation    && $(MAKE) distclean
distclean-gui:
	cd gui              && $(MAKE) distclean
