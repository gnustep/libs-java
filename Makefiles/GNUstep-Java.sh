#! /bin/sh
#
# GNUstepJava.sh
#
# Sets up all the variables needed to allow Objective-c stuff to find
# the Java libraries needed to start a JVM in your Objc code.
#
# Copyright (C) 2001 Free Software Foundation, Inc.
#
# Author: Nicola Pero <n.pero@mi.flashnet.it>
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
if [ -z "$JAVA_HOME" ]; then
  if [ -z "$JDK_HOME" ]; then
    if [ -z "$JAVAC" ]; then
      JAVA_HOME=`which javac  | sed "s/bin\/javac//g"`;
    else 
      JAVA_HOME=`which $JAVAC | sed "s/bin\/javac//g"`;
    fi;
  else 
    JAVA_HOME=$JDK_HOME; 
  fi
fi

export JAVA_HOME;

# Get the /lib dir into the jre installation
jre_lib="$JAVA_HOME/jre/lib"

###
### Determine the libraries needed to link and run native code starting
### a JVM inside. [the following is currently specific to SUN JDK]
###

# We should really examine the output of `java -version' to determine
# which flags to use exactly; the following works on SUN JDK 1.5.0
# but what about other platforms.

# PS: For older Sun's JDK, try using 'export JIGS_VM_TYPE=classic'
# before sourcing this script

# If no JIGS_THREAD_TYPE was set, use native_threads as a guess
if [ -z "$JIGS_THREAD_TYPE" ]; then
  JIGS_THREAD_TYPE=native_threads;
fi

# If no JIGS_VM_TYPE was set, use classic as a guess
if [ -z "$JIGS_VM_TYPE" ]; then
  JIGS_VM_TYPE=server;
fi

# For gnustep-make v2, we need to get the values of all the
# GNUSTEP_HOST_CPU variable.  This seems to be the most
# backwards-compatible way of doing it.  In gnustep-make v1, it will
# just source GNUstep.sh again with no changes.
GNUSTEP_SH_EXPORT_ALL_VARIABLES=yes
. $GNUSTEP_MAKEFILES/GNUstep.sh
unset GNUSTEP_SH_EXPORT_ALL_VARIABLES

# Convert the GNUSTEP_HOST_CPU into JAVA_CPU
case "$GNUSTEP_HOST_CPU" in
    ix86) JAVA_CPU=i386;;
    *)    JAVA_CPU=i386;;
esac

# Export the libraries needed to start a JVM
JIGS_VM_LIBS="-ljava -ljvm -lhpi"
export JIGS_VM_LIBS;

jre_cpu="$jre_lib/$JAVA_CPU"

# Export the -L flags needed
JIGS_VM_LIBDIRS="-L$jre_cpu -L$jre_cpu/$JIGS_THREAD_TYPE -L$jre_cpu/$JIGS_VM_TYPE"
export JIGS_VM_LIBDIRS;

# Now put the same paths into the appropriate LD_LIBRARY_PATH-like variable
j_lib_paths="$jre_cpu:$jre_cpu/$JIGS_THREAD_TYPE:$jre_cpu/$JIGS_VM_TYPE"

##
## Following part is Java environment independent again.
##

case "$GNUSTEP_HOST_OS" in

   *)
    if [ -z "$LD_LIBRARY_PATH" ]; then
      LD_LIBRARY_PATH="$j_lib_paths"
    else
      if ( echo ${LD_LIBRARY_PATH}| grep -v "${j_lib_paths}" >/dev/null );then
	LD_LIBRARY_PATH="$j_lib_paths:$LD_LIBRARY_PATH"
      fi
    fi
    export LD_LIBRARY_PATH;;

esac
