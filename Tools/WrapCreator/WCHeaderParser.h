/* HeaderParser: parse methods out of an objective-C header file -*-objc-*-

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

#ifndef __WCHeaderParser_h_GNUSTEP_WrapCreator_INCLUDE
#define __WCHeaderParser_h_GNUSTEP_WrapCreator_INCLUDE

#include <Foundation/Foundation.h>

@interface WCHeaderParser : NSObject
{
  NSString *header;
  NSMutableDictionary *classMethods;
  NSMutableDictionary *instanceMethods;
  NSMutableDictionary *enumerations;
  NSMutableDictionary *unresolvedTypedefs;
}

+ (NSString *) methodNameFromMethodDeclaration: (NSString *)declaration;

+ (id) newWithHeaderFile: (NSString *)fileName;

- (id) initWithHeaderFile: (NSString *)fileName;

- (NSString *) declarationOfMethod: (NSString *)methodName
		     isClassMethod: (BOOL)flag;

- (NSString *) getSuperclassOfClass: (NSString *)objcClassName;

- (NSArray *) enumerationTypes; 

- (NSDictionary *) dictionaryForEnumeration: (NSString *)enumeration;

@end

#endif
