#
#  Makefile for GNUstep Java Interface Library, C part, 
#  libgnustep-java-loader (a tiny initialization C library)
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
# We always compile this tiny library with debug=no profile=no 
# since we don't want its name to have _d or _p or _pd appended
#
override debug=no
override profile=no

GNUSTEP_INSTALLATION_DIR=$(GNUSTEP_SYSTEM_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make
include $(GNUSTEP_MAKEFILES)/jni.make

LIBRARY_NAME = libgnustep-java-loader

libgnustep-java-loader_C_FILES = JIGSLibraryLoader.c

ADDITIONAL_INCLUDE_DIRS += -I../../Java/
ADDITIONAL_OBJCFLAGS += -Wall

include $(GNUSTEP_MAKEFILES)/library.make




