#
#  Makefile for libName, a useless demo library
#  
#  Copyright (C) 2001 Free Software Foundation, Inc.
#
#  Written by: Nicola Pero <n.pero@mi.flashnet.it>
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

include $(GNUSTEP_MAKEFILES)/common.make

# The following two would mainly be useful if we were building RPMs
PACKAGE_NAME = NameLibrary
VERSION = 1.0.0

# The library
LIBRARY_NAME = libName
libName_HEADER_FILES = Name.h 
libName_OBJC_FILES = Name.m

# The wrappers for the library
JAVA_WRAPPER_NAME = Name
Name_HEADER_FILES = Name.h

include $(GNUSTEP_MAKEFILES)/library.make
include $(GNUSTEP_MAKEFILES)/java-wrapper.make

