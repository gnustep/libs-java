#
#  Copyright (C) 2001 Free Software Foundation, Inc.
#
#  Author:  Nicola Pero <nicola@brainstorm.co.uk>
#  Date: June 2001
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

all:
	@echo "Nothing to be done for all"

# Install the Makefiles
JIGS_MAKE_DIR = $(INSTALL_ROOT_DIR)$(GNUSTEP_MAKEFILES)

$(JIGS_MAKE_DIR):
	$(MKDIRS) $(JIGS_MAKE_DIR)

install: $(JIGS_MAKE_DIR)
	@echo "Installing GNUstep-Java.sh and jigs.make..."
	$(INSTALL_DATA) GNUstep-Java.sh $(JIGS_MAKE_DIR)
	chmod a+x $(JIGS_MAKE_DIR)/GNUstep-Java.sh
	$(INSTALL_DATA) jigs.make       $(JIGS_MAKE_DIR)

