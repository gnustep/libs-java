#
#  Makefile for GNUstep Java Interface Library, Objc part.
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

GNUSTEP_INSTALLATION_DIR=$(GNUSTEP_SYSTEM_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make
include $(GNUSTEP_MAKEFILES)/jni.make

SUBPROJECTS = loader

LIBRARY_NAME = libgnustep-java

VERSION = 1.5.5

libgnustep-java_HEADER_FILES = \
ObjcRuntimeUtilities.h \
GSJNI.h \
GSJNIArray.h \
GSJNICache.h \
GSJNIClass.h \
GSJNIDebug.h \
GSJNINumber.h \
GSJNIString.h \
NSJavaVirtualMachine.h \
JIGS.h \
JIGSBaseStruct.h \
JIGSException.h \
JIGSInit.h \
JIGSNative.h \
JIGSMapper.h \
JIGSProxy.h \
JIGSSelectorMapping.h \
java.lang.Object.h

libgnustep-java_HEADER_FILES_INSTALL_DIR = /$(GNUSTEP_FND_DIR)/java

libgnustep-java_C_FILES = \
ObjcRuntimeUtilities.c \

libgnustep-java_OBJC_FILES = \
ObjcRuntimeUtilities2.m \
GSJNIArray.m \
GSJNICache.m \
GSJNIClass.m \
GSJNIDebug.m \
GSJNINumber.m \
GSJNIString.m \
JIGSBaseStruct.m \
JIGSException.m \
JIGSInit.m \
JIGSMapper.m \
JIGSProxy.m \
JIGSProxySetup.m \
JIGSProxyIMP.m \
JIGSSelectorMapping.m \
NSJavaVirtualMachine.m \
JIGS.m \
NSObject.m     

LIBRARIES_DEPEND_UPON = $(FND_LIBS) $(CONFIG_SYSTEM_LIBS) $(OBJC_LIBS) 
ADDITIONAL_INCLUDE_DIRS += -I../Java/
ADDITIONAL_OBJCFLAGS += -Wall

include $(GNUSTEP_MAKEFILES)/library.make
include $(GNUSTEP_MAKEFILES)/aggregate.make

$(GNUSTEP_OBJ_DIR)/NSObject.o: JIGSNative.h
