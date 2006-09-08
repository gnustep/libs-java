#
#  Main Makefile for GNUstep Java Interface Library.
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

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = jigs
# Keep it in sync manually with Source/JIGS.h and Source/GNUmakefile
VERSION = 1.5.6

GNUSTEP_INSTALLATION_DIR=$(GNUSTEP_SYSTEM_ROOT)
RPM_DISABLE_RELOCATABLE=YES

CVS_MODULE_NAME = java
CVS_FLAGS = -d :pserver:anoncvs@subversions.gnu.org:/cvsroot/gnustep -z3
RELEASE_DIR = releases

# NB: "Java" must come before "Source"
# let Documentation be the last one, so even if it doesn't work,
# the software is built/installed anyway
SUBPROJECTS = Java Source Tools Makefiles Documentation

include $(GNUSTEP_MAKEFILES)/aggregate.make

