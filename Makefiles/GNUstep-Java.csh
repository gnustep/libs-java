#! /bin/csh
#
# GNUstepJava.csh
#
# Sets up all the variables needed to allow Objective-c stuff to find
# the Java libraries needed to start a JVM in your Objc code.
#
# Copyright (C) 2001 Free Software Foundation, Inc.
#
# Author: Nicola Pero <n.pero@mi.flashnet.it>
#
# Conversion to C-shell syntax: Wolfgang Lux <wolfgang.lux@gmail.com>
#
# This file is part of JIGS, the GNUstep Java Interface
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#   
# You should have received a copy of the GNU General Public
# License along with this library; see the file COPYING.LIB.
# If not, write to the Free Software Foundation,
# 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


# You need to source this script before compiling and executing
# Objective-C stuff which loads and runs a JVM.

###
### Determine the JRE /lib directory. [should work with all JRE]
###

# Set JAVA_HOME to point to the root of the Java installation
if ( ! ${?JAVA_HOME} ) then
  if ( ! ${?JDK_HOME} ) then
    if ( ! ${?JAVAC} ) then
      setenv JAVA_HOME `which javac  | sed "s/bin\/javac//g"`
    else 
      setenv JAVA_HOME `which $JAVAC | sed "s/bin\/javac//g"`
    endif
  else
    setenv JAVA_HOME "$JDK_HOME"
  endif
endif

# Get the /lib dir into the jre installation
set jre_lib = "$JAVA_HOME/jre/lib"

###
### Determine the libraries needed to link and run native code starting
### a JVM inside. [the following is currently specific to SUN JDK]
###

# We should really examine the output of `java -version' to determine
# which flags to use exactly; the following works on SUN JDK 1.5.0
# but what about other platforms.

# PS: For older Sun's JDK, try using 'setenv JIGS_VM_TYPE classic'
# before sourcing this script

# If no JIGS_THREAD_TYPE was set, use native_threads as a guess
if ( ! ${?JIGS_THREAD_TYPE} ) then
  setenv JIGS_THREAD_TYPE native_threads
endif

# If no JIGS_VM_TYPE was set, use classic as a guess
if ( ! ${?JIGS_VM_TYPE} ) then
  setenv JIGS_VM_TYPE server
endif

# For gnustep-make v2, we need to get the values of all the
# GNUSTEP_HOST_CPU variable.
set GNUSTEP_HOST_CPU = "`gnustep-config --variable=GNUSTEP_HOST_CPU`"

# Convert the GNUSTEP_HOST_CPU into JAVA_CPU
switch ( "$GNUSTEP_HOST_CPU" )
case ix86:
  setenv JAVA_CPU i386
  breaksw
default:
  setenv JAVA_CPU "$GNUSTEP_HOST_CPU"
  breaksw
endsw

# Export the libraries needed to start a JVM
setenv JIGS_VM_LIBS "-ljava -ljvm -lhpi"

set jre_cpu = "$jre_lib/$JAVA_CPU"

# Export the -L flags needed
setenv JIGS_VM_LIBDIRS "-L$jre_cpu -L$jre_cpu/$JIGS_THREAD_TYPE -L$jre_cpu/$JIGS_VM_TYPE"

# Now put the same paths into the appropriate LD_LIBRARY_PATH-like variable
set j_lib_paths = "${jre_cpu}:${jre_cpu}/${JIGS_THREAD_TYPE}:${jre_cpu}/${JIGS_VM_TYPE}"

##
## Following part is Java environment independent again.
##

switch ( "$GNUSTEP_HOST_OS" )

default:
  if ( ! ${?LD_LIBRARY_PATH} ) then
    setenv LD_LIBRARY_PATH "$j_lib_paths"
  else
    echo ${LD_LIBRARY_PATH} | grep "${j_lib_paths}" >/dev/null
    if ( $status != 0 ) then
      setenv LD_LIBRARY_PATH "${j_lib_paths}:$LD_LIBRARY_PATH"
    endif
  endif

endsw
