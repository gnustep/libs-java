#  NSObjectTest: test of gnu.gnustep.base.NSObject
#
#  Copyright (C) 2000 Free Software Foundation, Inc.
#
#  Author:  Nicola Pero <n.pero@mi.flashnet.it>
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

JAVA_PACKAGE_NAME = gnu.gnustep.java-test

#
# Keep the gui tests after the base tests so that people can 
# compile all the base tests anyway if they don't use the gui
#
gnu.gnustep.java-test_JAVA_FILES =       \
    NSObjectTest.java                    \
    NSObjectSubclassTest.java            \
    NSArrayTest.java                     \
    NSProcessInfoTest.java               \
    NSDateTest.java                      \
    NSTaskTest.java                      \
    NSNotificationCenterTest.java        \
    NSSelectorTest.java                  \
    NSPropertyListSerializationTest.java \
    NSApplicationTest.java              



include $(GNUSTEP_MAKEFILES)/java.make


