/* JIGSProxyIMP.h - The forwarding routine to Java

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
   This file is part of the GNUstep Java Interface Library.

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

#ifndef __JIGSProxyIMP_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSProxyIMP_h_GNUSTEP_JAVA_INCLUDE

#include <objc/objc-api.h>
#include <jni.h>
/*
 * The design of the forwarding routines for the GNUstep Java
 * Interface Library was mainly inspired to the goal of making them as
 * portable as possible.  
 * 
 * The best portability is in this case achieved with the most simple
 * and somewhat stupid implementation: we implement a different IMP
 * (forwarding routine) for each return type.  In this way, we avoid
 * any tricking with the C stack: the code will compile and run fine
 * on any machine.
 * 
 * The main disadvantage is that nearly the same code is repeated in
 * 10 different functions.  We try to reduce this problem by using
 * macros.  This makes the code a bit more difficult to manage than
 * usual.  
 */

jboolean _JIGS_jboolean_IMP_JavaMethod (id rcv, SEL sel, ...);
jbyte    _JIGS_jbyte_IMP_JavaMethod    (id rcv, SEL sel, ...);
jchar    _JIGS_jchar_IMP_JavaMethod    (id rcv, SEL sel, ...);
jshort   _JIGS_jshort_IMP_JavaMethod   (id rcv, SEL sel, ...);
jint     _JIGS_jint_IMP_JavaMethod     (id rcv, SEL sel, ...);
jlong    _JIGS_jlong_IMP_JavaMethod    (id rcv, SEL sel, ...);
jfloat   _JIGS_jfloat_IMP_JavaMethod   (id rcv, SEL sel, ...);
jdouble  _JIGS_jdouble_IMP_JavaMethod  (id rcv, SEL sel, ...);
jobject  _JIGS_id_IMP_JavaMethod       (id rcv, SEL sel, ...);
void     _JIGS_void_IMP_JavaMethod     (id rcv, SEL sel, ...);

#endif /* __JIGSProxyIMP_h_GNUSTEP_JAVA_INCLUDE */
