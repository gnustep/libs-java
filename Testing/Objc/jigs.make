#
#   jigs.make
#
#   Makefile to include to compile Objective-C programs 
#            accessing Java classes through JIGS
#
#   Copyright (C) 2000 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <nicola@brainstorm.co.uk> 
#
#   This file is part of the GNUstep Makefile Package.
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

#
# FIXME: This is correct on my linux, but how do we get it if different 
#        from native_thread... ?
#
JAVA_THREAD_TYPE = native_threads
#
# Now what a pain.  GNUSTEP_HOST_CPU is ix86 instead on my system.
#
JAVA_CPU = i386

#
# Probably completely system-dependent stuff goes here
#

# SUN JDK 1.2.2
JAVA_VM_LIBS = -ljava -ljvm -lhpi

# BLACKDOWN JDK 1.3.0
#JAVA_VM_LIBS = -ljava -ljvm -lhpi -lverify

JAVA_VM_LIB_DIRS = -L$(JAVA_HOME)/jre/lib/$(JAVA_CPU)/ \
                   -L$(JAVA_HOME)/jre/lib/$(JAVA_CPU)/$(JAVA_THREAD_TYPE)/ \
                   -L$(JAVA_HOME)/jre/lib/$(JAVA_CPU)/classic

#
# The rest does not depend on system
#
ADDITIONAL_LIB_DIRS += $(JAVA_VM_LIB_DIRS)
ADDITIONAL_OBJC_LIBS += $(JAVA_VM_LIBS)
ADDITIONAL_OBJC_LIBS += -lgnustep-java

endif # jigs.make loaded

## Local variables:
## mode: makefile
## End:

