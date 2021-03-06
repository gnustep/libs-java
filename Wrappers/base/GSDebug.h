/* GSDebug.h -*-objc-*-
   Copyright (C) 2003 Free Software Foundation, Inc.

   Written by: Nicola Pero <n.pero@mi.flashnet.it>
   Date: October 2003

   This file is part of JIGS, the GNUstep Java Interface.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
  */

#ifndef _JIGS_GSDEBUG_H
#define _JIGS_GSDEBUG_H

#include <Foundation/Foundation.h>

@interface GSDebug : NSObject

+ (BOOL) allocationActiveRecordingObjects: (NSString*)className;
+ (BOOL) allocationActive: (BOOL)flag;
+ (NSString*) allocationList: (BOOL)flag;
+ (NSArray*) allocationListRecordedObjects: (NSString*)className;

/*
 * Turn on/off debugging of allocation.  Equivalent to
 * GSDebugAllocationActive (active);
 */
+ (void) setDebugAllocationActive: (BOOL)active;

/*
 * Print to stderr the allocation list of all allocated objects.
 * Equivalent to
 *
 * fprintf (stderr, GSDebugAllocationList (false));
 *
 */
+ (void) printAllocationList;

/*
 * Print to stderr the changes in the allocation list of all allocated
 * objects - changes from last check.  Equivalent to
 *
 * fprintf (stderr, GSDebugAllocationList (true));
 *
 */
+ (void) printAllocationListSinceLastCheck;

@end

#endif /* _JIGS_GSDEBUG_H */
