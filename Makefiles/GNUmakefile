#
#  Copyright (C) 2001 - 2010 Free Software Foundation, Inc.
#
#  Author:  Nicola Pero <nicola.pero@meta-innovation.com>
#  Date: June 2001 - February 2010
#   
#  This file is part of GNUstep.
#   
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#   
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#   
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

include $(GNUSTEP_MAKEFILES)/common.make

all::

clean::

distclean::
	-$(ECHO_NOTHING)rm -f *~$(END_ECHO)

check::

# Install the Makefiles
JIGS_MAKE_DIR = $(DESTDIR)$(GNUSTEP_MAKEFILES)

$(JIGS_MAKE_DIR):
	$(ECHO_CREATING)$(MKINSTALLDIRS) $@$(END_ECHO)

install:: $(JIGS_MAKE_DIR)
	$(ECHO_NOTHING)$(INSTALL_DATA) jigs.make $(JIGS_MAKE_DIR); \
	$(INSTALL_PROGRAM) -m 755 GNUstep-Java.sh $(JIGS_MAKE_DIR); \
	$(INSTALL_PROGRAM) -m 755 GNUstep-Java.csh $(JIGS_MAKE_DIR)$(END_ECHO)


uninstall::
	$(ECHO_NOTHING)rm -f $(JIGS_MAKE_DIR)/GNUstep-Java.sh $(JIGS_MAKE_DIR)/GNUstep-Java.csh $(JIGS_MAKE_DIR)/jigs.make$(END_ECHO)

include $(GNUSTEP_MAKEFILES)/rules.make