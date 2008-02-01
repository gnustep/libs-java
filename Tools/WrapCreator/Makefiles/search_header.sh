#! /bin/sh
#
#  Looks for a header file in ./, then in the GNUSTEP standard header dirs
#
#  Copyright (C) 2001-2008 Free Software Foundation, Inc.
#
#  Author:  Nicola Pero <nicola.pero@meta-innovation.com>
#  Date: May 2001, January 2008
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

header_file="$1";
header_file_dir="$2";
current_dir=`pwd`;

# If a second argument was given, it is a directory to search the
# header in - try that first
if [ -n "$header_file_dir" ]; then 

  case "$header_file_dir" in
    /*) # An absolute path
        ;;
     *) # A relative path
        header_file_dir="$current_dir/$header_file_dir";;
  esac

  if [ -f "$header_file_dir/$header_file" ]; then
    echo "$header_file_dir/$header_file";
    exit 0;
  fi

fi



attempt="$current_dir/$header_file";

if [ -f "$attempt" ]; then 
  echo "$attempt";
  exit 0;
fi

# For gnustep-make v2, we need to get the values of all the
# GNUSTEP_XXX_HEADERS variables.  This seems to be the most
# backwards-compatible way of doing it.  In gnustep-make v1, it will
# just source GNUstep.sh again with no changes.
GNUSTEP_SH_EXPORT_ALL_VARIABLES=yes
. $GNUSTEP_MAKEFILES/GNUstep.sh
unset GNUSTEP_SH_EXPORT_ALL_VARIABLES

# If GNUSTEP_USER_HEADERS is undefined, we may be running under
# gnustep-make v1; try using GNUSTEP_USER_ROOT then.
if [ -z "$GNUSTEP_USER_HEADERS" ]; then
  GNUSTEP_USER_HEADERS="$GNUSTEP_USER_ROOT/Headers"
fi
attempt="$GNUSTEP_USER_HEADERS/$header_file"

if [ -f "$attempt" ]; then 
  echo "$attempt";
  exit 0;
fi

if [ -z "$GNUSTEP_LOCAL_HEADERS" ]; then
  GNUSTEP_LOCAL_HEADERS="$GNUSTEP_LOCAL_ROOT/Headers"
fi
attempt="$GNUSTEP_LOCAL_HEADERS/$header_file"

if [ -f "$attempt" ]; then 
  echo "$attempt";
  exit 0;
fi

if [ -z "$GNUSTEP_NETWORK_HEADERS" ]; then
  GNUSTEP_NETWORK_HEADERS="$GNUSTEP_NETWORK_ROOT/Headers"
fi
attempt="$GNUSTEP_NETWORK_HEADERS/$header_file"

if [ -f "$attempt" ]; then 
  echo "$attempt";
  exit 0;
fi

if [ -z "$GNUSTEP_SYSTEM_HEADERS" ]; then
  GNUSTEP_SYSTEM_HEADERS="$GNUSTEP_SYSTEM_ROOT/Headers"
fi
attempt="$GNUSTEP_SYSTEM_HEADERS/$header_file"

if [ -f "$attempt" ]; then 
  echo "$attempt";
  exit 0;
fi

exit 1;