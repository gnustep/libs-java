#
#  GNUstep Java Interface Library, makefile for Objc code
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
include $(GNUSTEP_MAKEFILES)/jni.make

#
# By default, the objective-C wrapping library is called 
# like the original one, with a .A appended
#

LIBRARY_NAME = libSimpleGUI.A
libSimpleGUI.A_OBJC_FILES =  SimpleGUI.m

#
# TODO: Refine the following code and move it somewhere in the make package
# A java-wrap-library.make which simply includes library.make + the following ?
#

# Libraries any .A library depends upon
LIBRARIES_DEPEND_UPON += -lgnustep-java -lgnustep-base -lobjc -lc

# Libraries that a gui .A library depends upon
LIBRARIES_DEPEND_UPON += -lgnustep-gui -lgmodel -lgnustep-xgps 

# Any .A library depends upon the library it is wrapping
LIBRARIES_DEPEND_UPON += -lSimpleGUI

#
# END TODO
#

# The following is only to allow the user to compile before having installed 
# the library
ADDITIONAL_LIB_DIRS += -L../../Library/$(GNUSTEP_OBJ_DIR)

include $(GNUSTEP_MAKEFILES)/library.make
