#
#   jigs.make
#
#   Makefile to include to compile Objective-C programs 
#            accessing Java classes through JIGS
#
#   Copyright (C) 2000, 2001 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk> 
#
#   This file is part of JIGS, the GNUstep Java Interface
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# prevent multiple inclusions
ifeq ($(JIGS_MAKE_LOADED),)
JIGS_MAKE_LOADED=yes

# We need JNI.  This includes the jni headers
include $(GNUSTEP_MAKEFILES)/jni.make

# GNUstep-Java.sh should have set JIGS_VM_LIBDIRS and JIGS_VMLIBS
ifeq ($(JIGS_VM_LIBS),)
  $(error You need to source GNUstep-Java.sh before compiling!)
endif

ADDITIONAL_LIB_DIRS += $(JIGS_VM_LIBDIRS)
ADDITIONAL_OBJC_LIBS += $(JIGS_VM_LIBS)
ADDITIONAL_OBJC_LIBS += -lgnustep-java

endif # jigs.make loaded

## Local variables:
## mode: makefile
## End:

