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

internal-all ::

install :: 
	@echo ===================================================
	@echo
	@echo You should never install this fake library !
	@echo
	@echo By typing \'make\' in this directory the wrapper 
	@echo library is created in ./JavaWrapper.
	@echo
	@echo So, please type \'make\', then cd into JavaWrapper, 
	@echo and compile and install the wrapper library there.  
	@echo 
	@echo ===================================================
	@echo
	@echo Now trying to abort...
	@echo
	@stop-execution-of-this-makefile-please

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = gnustep-base

# NB: VERSION should be the same as the gnustep-base library version
# we are wrapping.  
ifeq ($(GNUSTEP_BASE_VERSION),)
  $(error ERROR: your gnustep base library is too old !)
else
  VERSION = $(GNUSTEP_BASE_VERSION)
endif

LIBRARY_NAME = libgnustep-base

include $(GNUSTEP_MAKEFILES)/library.make

include $(GNUSTEP_MAKEFILES)/java-wrapper.make

after-distclean::
	rm -f $(PACKAGE_NAME)-wrapper-$(VERSION).tar.gz
	rm -f $(PACKAGE_NAME)-wrapper-debug-$(VERSION).tar.gz
