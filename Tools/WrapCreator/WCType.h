/* WCType.h: An abstract class for objc/java type conversion -*-objc-*-

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

/*
 * WCType encapsulates a type that can be converted from objective-C to java
 * and rules to convert it.
 *
 * WCTypes are shared - only a single shared WCType object representing a
 * string type is created, for example.
 *
 * WCType is an abstract class.  Concrete subclasses are created as needed
 * by the WCTypeLoader class.
 *
 */


#ifndef __WCType_h_GNUSTEP_WrapCreator_INCLUDE
#define __WCType_h_GNUSTEP_WrapCreator_INCLUDE

#include <Foundation/Foundation.h>

@interface WCType : NSObject
{
  NSString *objcType;   /* @"String" */
}

/*
 * Return the type for objective-C type 'name'. 
 * Call WCTypeLoader if needed to create a new WCType.
 *
 */
+ (WCType *) sharedTypeWithObjcType: (NSString *)name;

/*
 * The same, but only return the type is it was already created; 
 * otherwise return nil without calling the WCTypeLoader.  Mainly 
 * provided because it is handy in initWithObjcType:.
 *
 */
+ (WCType *) existingSharedTypeWithObjcType: (NSString *)name;

- (id) initWithObjcType: (NSString *)type;

- (NSString *) javaType;

- (NSString *) objcType;

- (NSString *) jniType;

- (BOOL) isVoidType;

/*
 * Eg: if StringType is the shared Type for strings, 
 * [StringType codeToConvertToObjc: @"var1" givingResult: @"var0"]; will output: 
 * @"var1 = GSJNI_NSStringFromJString (env, var0);"
 *
 */
- (NSString *) codeToConvertToObjc: (NSString *)jniArgument
		      givingResult: (NSString *)objcResult;

/*
 * Eg: if StringType is the shared Type for strings, 
 * [StringType codeToConvertToJava: @"var1" givingResult: @"var0"]; will output: 
 * @"var1 = GSJNI_JStringFromNSString (env, var0);"
 *
 */
- (NSString *) codeToConvertToJava: (NSString *)objcArgument
		      givingResult: (NSString *)jniResult;
@end

#endif /* __WCType_h_GNUSTEP_WrapCreator_INCLUDE */
