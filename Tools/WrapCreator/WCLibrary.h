/* WCLibrary.h: A library to be wrapped          -*-objc-*-

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: August 2000
   
   This file is part of JIGS, the GNUstep Java Interface.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#ifndef __WCLibrary_h_GNUSTEP_WrapCreator_INCLUDE
#define __WCLibrary_h_GNUSTEP_WrapCreator_INCLUDE

#include <Foundation/Foundation.h>

@class WCHeaderParser;

@interface WCLibrary : NSObject
{}
+ (NSString *) libraryName;

+ (NSString *) shortLibraryName;

+ (WCHeaderParser *) headerParser;

+ (NSString *) libraryHeader;

+ (BOOL) verboseOutput;

+ (BOOL) outputJavadoc;

+ (void) initializeWithOptions: (NSDictionary *)options;

+ (void) outputWrappers;

+ (NSString *) javaMethodForObjcMethod: (NSString *)methodName;

+ (NSArray *) prerequisiteLibraries;

+ (void) createJavaDirectoryForClass: (NSString *)fullJavaClassName;

+ (NSString *) javaWrapperFileForClass: (NSString *)fullJavaClassName;

+ (NSString *) objcWrapperFileForClass: (NSString *)objcClassName;

+ (NSString *) selectorMapFileForClass: (NSString *)objcClassName;

/* The following returns the contents of the file at
   top_directory/relativePath - where top_directory is the one in
   which the jigs file is kept. */
+ (NSString *) fileWithRelativePath: (NSString *)relativePath;

/* The following will look into our class list, and then into 
   class name mappings specified by the `hints' entries in the 
   .jigs file */
+ (NSString *) javaClassNameForObjcClassName: (NSString*)objcClassName;

@end

#endif
