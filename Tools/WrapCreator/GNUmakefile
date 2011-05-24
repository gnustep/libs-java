#
#  Copyright (C) 2000 Free Software Foundation, Inc.
#
#  Author:  Nicola Pero <nicola@brainstorm.co.uk>
#  Date: July 2000
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

TOOL_NAME = WrapCreator

WrapCreator_OBJC_FILES = \
WCLibrary.m \
WCHeaderParser.m \
WCClass.m \
WCMethod.m \
WCBOOLType.m \
WCNSIntegerType.m \
WCNSUIntegerType.m \
WCCGFloatType.m \
WCCharType.m \
WCCustomType.m \
WCDoubleType.m \
WCFloatType.m \
WCIdType.m \
WCIntType.m \
WCLongType.m \
WCShortType.m \
WCUnsignedIntType.m \
WCUnsignedLongType.m \
WCUnsignedShortType.m \
WCLongLongType.m \
WCUnsignedLongLongType.m \
WCMorphType.m \
WCObjectType.m \
WCPrimitiveType.m \
WCType.m \
WCTypeLoader.m \
WCVoidType.m \
main.m

ADDITIONAL_OBJCFLAGS += -Wall

include $(GNUSTEP_MAKEFILES)/tool.make

# Install the Makefiles
JIGS_MAKE_DIR = $(DESTDIR)$(GNUSTEP_MAKEFILES)
after-install::
	$(ECHO_NOTHING)$(MKINSTALLDIRS) $(JIGS_MAKE_DIR); \
	$(INSTALL_DATA) Makefiles/java-wrapper.make \
	                Makefiles/java-wrapper.top.template \
	                Makefiles/java-wrapper.readme.template \
	                Makefiles/java-wrapper.objc.template \
	                Makefiles/java-wrapper.java.template $(JIGS_MAKE_DIR); \
	$(INSTALL_PROGRAM) -m 755 Makefiles/search_header.sh $(JIGS_MAKE_DIR)$(END_ECHO)
before-uninstall::
	$(ECHO_NOTHING)rm -f \
	      $(JIGS_MAKE_DIR)/java-wrapper.make \
	      $(JIGS_MAKE_DIR)/java-wrapper.top.template \
	      $(JIGS_MAKE_DIR)/java-wrapper.readme.template \
	      $(JIGS_MAKE_DIR)/java-wrapper.objc.template \
	      $(JIGS_MAKE_DIR)/java-wrapper.java.template \
	      $(JIGS_MAKE_DIR)/search_header.sh$(END_ECHO)
