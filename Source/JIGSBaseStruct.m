/* JIGSBaseStruct.m - Morphing NSPoint, NSSize, NSRect, NSRange
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
   This file is part of JIGS, the GNUstep Java Interface Library.

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

#include "JIGSBaseStruct.h"

/*
 * Cache
 */

static jclass nspoint = NULL;
static jmethodID new_point = NULL;
static jfieldID point_x = NULL;
static jfieldID point_y = NULL;

static jclass nssize = NULL;
static jmethodID new_size = NULL;
static jfieldID size_width = NULL;
static jfieldID size_height = NULL;

static jclass nsrect = NULL;
static jmethodID new_rect = NULL;
static jfieldID rect_x = NULL;
static jfieldID rect_y = NULL;
static jfieldID rect_width = NULL;
static jfieldID rect_height = NULL;

static jclass nsrange = NULL;
static jmethodID new_range = NULL;
static jfieldID range_location = NULL;
static jfieldID range_length = NULL;

/*
 * Initialize the cache, all at the beginning. 
 * Need to be called before any of the other methods. 
 * Called automatically at startup by JIGSInit ().
 */
void _JIGSBaseStructInitialize (JNIEnv *env)
{
#define _JIGS_check_null(variable) if (variable == NULL) return;

  if (range_length == NULL)
    {
      // NSPoint
      nspoint = GSJNI_NewClassCache (env, "gnu/gnustep/base/NSPoint");
      _JIGS_check_null (nspoint);
      
      new_point = (*env)->GetMethodID (env, nspoint, "<init>", "(FF)V");
      _JIGS_check_null (new_point);  
      
      point_x = (*env)->GetFieldID (env, nspoint, "x", "F");  
      _JIGS_check_null (point_x);  
      
      point_y = (*env)->GetFieldID (env, nspoint, "y", "F");  
      _JIGS_check_null (point_y);  
      
      // NSSize
      nssize = GSJNI_NewClassCache (env, "gnu/gnustep/base/NSSize");
      _JIGS_check_null (nssize);
      
      new_size = (*env)->GetMethodID (env, nssize, "<init>", "(FF)V");
      _JIGS_check_null (new_size);  
      
      size_width = (*env)->GetFieldID (env, nssize, "width", "F");  
      _JIGS_check_null (size_width);  
      
      size_height = (*env)->GetFieldID (env, nssize, "height", "F");  
      _JIGS_check_null (size_height);  
      
      // NSRect
      nsrect = GSJNI_NewClassCache (env, "gnu/gnustep/base/NSRect");
      _JIGS_check_null (nsrect);
      
      new_rect = (*env)->GetMethodID (env, nsrect, "<init>", "(FFFF)V");
      _JIGS_check_null (new_rect);  
      
      rect_x = (*env)->GetFieldID (env, nsrect, "x", "F");  
      _JIGS_check_null (rect_x);  
      
      rect_y = (*env)->GetFieldID (env, nsrect, "y", "F");  
      _JIGS_check_null (rect_y);  
      
      rect_width = (*env)->GetFieldID (env, nsrect, "width", "F");  
      _JIGS_check_null (rect_width);  
      
      rect_height = (*env)->GetFieldID (env, nsrect, "height", "F");  
      _JIGS_check_null (rect_height);
      
      // NSRange
      nsrange = GSJNI_NewClassCache (env, "gnu/gnustep/base/NSRange");
      _JIGS_check_null (nsrange);
      
      new_range = (*env)->GetMethodID (env, nsrange, "<init>", "(II)V");
      _JIGS_check_null (new_range);  
      
      range_location = (*env)->GetFieldID (env, nsrange, "location", "I");  
      _JIGS_check_null (range_location);  
      
      range_length = (*env)->GetFieldID (env, nsrange, "length", "I");  
      _JIGS_check_null (range_length);
    }
#undef _JIGS_check_null
}

/*
 * The morphing functions 
 */

NSPoint JIGSNSPointConvertToStruct (JNIEnv *env, jobject point)
{
  NSPoint output;
  
  output.x = (*env)->GetFloatField (env, point, point_x);
  output.y = (*env)->GetFloatField (env, point, point_y);
  
  return output;
}

jobject JIGSNSPointConvertToJobject (JNIEnv *env, NSPoint point)
{
  jobject output;
  
  output = (*env)->NewObject (env, nspoint, new_point, point.x, 
			      point.y);
  // return NULL upon exception thrown
  return output;
}


NSSize JIGSNSSizeConvertToStruct (JNIEnv *env, jobject size)
{
  NSSize output;
  
  output.width = (*env)->GetFloatField (env, size, size_width);
  output.height = (*env)->GetFloatField (env, size, size_height);
  
  return output;  
}

jobject JIGSNSSizeConvertToJobject (JNIEnv *env, NSSize size)
{
  jobject output;
  
  output = (*env)->NewObject (env, nssize, new_size, size.width, 
			      size.height);
  // return NULL upon exception thrown
  return output;  
}


NSRect JIGSNSRectConvertToStruct (JNIEnv *env, jobject rect)
{
  NSRect output;
  
  output.origin.x = (*env)->GetFloatField (env, rect, rect_x);
  output.origin.y = (*env)->GetFloatField (env, rect, rect_y);  
  output.size.width = (*env)->GetFloatField (env, rect, rect_width);
  output.size.height = (*env)->GetFloatField (env, rect, rect_height);
  
  return output;    
}


jobject JIGSNSRectConvertToJobject (JNIEnv *env, NSRect rect)
{
  jobject output;
  
  output = (*env)->NewObject (env, nsrect, new_rect, rect.origin.x, 
			      rect.origin.y, rect.size.width, 
			      rect.size.height);
  // return NULL upon exception thrown
  return output;    
}


NSRange JIGSNSRangeConvertToStruct (JNIEnv *env, jobject range)
{
  NSRange output;
  
  output.location = (*env)->GetIntField (env, range, range_location);
  output.length = (*env)->GetIntField (env, range, range_length);  
  
  return output;    
}

jobject JIGSNSRangeConvertToJobject (JNIEnv *env, NSRange range)
{
  jobject output;
  
  output = (*env)->NewObject (env, nsrange, new_range, range.location, 
			      range.length);
  // return NULL upon exception thrown
  return output;    
}

