/* JIGSProxyIMP.m - Forwarding routines to Java
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <n.pero@mi.flashnet.it>
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

#include "JIGSProxySetup.h"
#include "NSJavaVirtualMachine.h"
#include "java.lang.Object.h"
#include "JIGSException.h"
#include "JIGSMapper.h"
#include <pthread.h>
#include "JIGSSelectorMapping.h"

// From JIGSProxySetup.m
extern struct _JIGSSelectorIDTable *_JIGS_selIDTable;
extern pthread_mutex_t _JIGS_selIDTableLock;
extern char _JAVA_BOOLEAN;
extern char _JAVA_BYTE;
extern char _JAVA_CHAR;
extern char _JAVA_SHORT;
extern char _JAVA_INT;
extern char _JAVA_LONG;
extern char _JAVA_FLOAT;
extern char _JAVA_DOUBLE;

/*
 *
 * MACROS AND INLINE FUNCTIONS 
 *
 */

/*
 * Operations on the _JIGS_selIDTable
 */

#define CHECK_THE_TABLE                                        \
  if (_JIGS_selIDTable == NULL)                              \
    {                                                          \
      NSLog (@"MESSAGE_SELIDTABLE_NULL");                      \
      return 0;                                                \
    }                                                          

#define CHECK_THE_TABLE_NO_RETURN                              \
  if (_JIGS_selIDTable == NULL)                              \
    {                                                          \
      NSLog (@"MESSAGE_SELIDTABLE_NULL");                      \
      return;                                                  \
    }                                                          

#define LOCK_THE_TABLE pthread_mutex_lock (&_JIGS_selIDTableLock)
#define UNLOCK_THE_TABLE pthread_mutex_unlock (&_JIGS_selIDTableLock)

#define CHECK_UNLOCK(condition, message, fail_return)      \
  if (condition)                                           \
    {                                                      \
      NSLog (@#message);                                   \
      UNLOCK_THE_TABLE;                                    \
      return (fail_return);                                \
    }  

#define CHECK_UNLOCK_NO_RETURN(condition, message) \
  if (condition)                                   \
    {                                              \
      NSLog (@#message);                           \
      UNLOCK_THE_TABLE;                            \
      return;                                      \
    }   

/*
 * Related messages 
 */
      
#define MESSAGE_SELIDTABLE_NULL Critical Warning: \
Java IMP invoked before the selIDTable was created !

#define MESSAGE_SELDITABLE_0 Critical Warning: \
Java IMP invoked before the selIDTable contained anything !

#define MESSAGE_CLASS_NOT_IN_SELIDTABLE Critical Warning: \
Java IMP invoked on object/class not registered in the selIDTable !

#define MESSAGE_NULL_CLASS_IN_SELIDTABLE Critical Warning: \
Java IMP invoked on class correspoding to a null java class !

#define MESSAGE_SELECTOR_NOT_IN_SELIDTABLE Critical Warning: \
Java IMP invoked but could find class but not selector !

/*
 * Inlined operations on the table
 */

static inline int 
find_class_in_selIDTable (Class aClass)
{
  int i;
  
  for (i = 0; i < _JIGS_selIDTable->classCount; i++)
    {
      if (_JIGS_selIDTable->classTable[i].class == aClass)
	{
	  return i;
	}
    }
  return -1;
}

static inline int
find_selector_in_selIDTable (int k, SEL aSelector)
{
  int i;

  for (i = 0; i < _JIGS_selIDTable->classTable[k].selIDCount; i++)
    {
      if (sel_isEqual (_JIGS_selIDTable->classTable[k].selIDTable[i].selector, 
		       aSelector))  
	{                                                      
	  return i;	
	}                                                      
    }
  return -1;
}

/*
 * Get the java receiver if needed
 */
#define GET_RECEIVER                                      \
    if (class_isMetaClass(class) == NO)                   \
      {                                                   \
	jrcv = ((_java_lang_Object *)rcv)->realObject;    \
      }


/*
 * Processing of arguments
 */

/* Skip past an argument and also any offset information
 * and type qualifiers before the next.
 */
static inline const char *
skip_argspec(const char *ptr)
{
  if (ptr != NULL)
    {
      if (*ptr == '+') ptr++;
      while (isdigit(*ptr)) ptr++;
      ptr = objc_skip_typespec(ptr);
      if (*ptr == '+') ptr++;
      while (isdigit(*ptr)) ptr++;
      ptr = objc_skip_type_qualifiers(ptr);
    }
  return ptr;
}
/*
 * Macros to process the whole list of arguments
 */

#define INIT_PROCESS_ARGS              \
      type = skip_argspec (type); \
      type = skip_argspec (type); \
      type = skip_argspec (type); \
                                       \
      va_start (ap, sel);              \
      i = 0;

#define DO_PROCESS_ARGS  \
while (*type != '\0') {  \
if (*type == _C_ID)\
  {\
    args[i].l = JIGSJobjectFromId (env, va_arg (ap, id));\
  }\
else if (*type == _C_CLASS)\
  {\
    NSLog (@"Critical - (class) argument of java method not supported yet!");\
    args[i].i = 0;\
  }\
else if (*type == _C_STRUCT_B)\
  {\
    NSLog (@"Critical - a struct as argument of java method ?");\
    args[i].i = 0;\
  }\
else if (*type == _C_SEL)\
  {\
    args[i].l = JIGSNSSelectorFromSEL (env, va_arg (ap, SEL));\
  }\
else if (*type == _JAVA_BOOLEAN)\
  {\
     args[i].z = (jboolean)(va_arg (ap, int));\
  }\
else if (*type == _JAVA_BYTE)\
  {\
    args[i].b = (jbyte)(va_arg (ap, int));\
  }\
else if (*type == _JAVA_CHAR)\
  {\
    args[i].c = (jchar)(va_arg (ap, int /* FIXME: unsigned int ? */));\
  }\
else if (*type == _JAVA_SHORT)\
  {\
    args[i].s = (jshort)(va_arg (ap, int));\
  }\
else if (*type == _JAVA_INT)\
  {\
    args[i].i = va_arg (ap, jint);\
  }\
else if (*type == _JAVA_LONG)\
  {\
    args[i].j = va_arg (ap, jlong);\
  }\
else if (*type == _JAVA_FLOAT)\
  {\
    /* FIXME: on gcc 2.91-66 this must be "va_arg (ap, jfloat)" */\
    args[i].f = (jfloat)(va_arg (ap, double));\
  }\
else if (*type == _JAVA_DOUBLE)\
  {\
    args[i].d = va_arg (ap, jdouble);\
  }\
else if (*type == _C_CHARPTR)\
  {\
    NSLog (@"Critical - (char *) as argument of java method ?");\
    args[i].i = 0;\
  }\
else if (*type == _C_PTR)\
  {\
    NSLog (@"Critical - (void *) as argument of java method ?");\
    args[i].i = 0;\
  }\
else\
  {\
    [NSException raise: NSInvalidArgumentException\
		 format: @"_JIGS_IMP_JavaMethod - "\
		 @"unrecognized Objc type"];\
  }\
type = skip_argspec (type);\
i++; }

#define END_PROCESS_ARGS va_end(ap);

#define PROCESS_ARGS                              \
  args = alloca (numberOfArgs * sizeof (jvalue)); \
                                                  \
  if (numberOfArgs > 0) {                         \
    INIT_PROCESS_ARGS                             \
    DO_PROCESS_ARGS                               \
    END_PROCESS_ARGS }

/*
 * Running a java method
 */

#define RUN_JAVA_METHOD(type)                                   \
      if (class_isMetaClass (class))                            \
	{                                                       \
	  if (numberOfArgs == 0)                                \
	    ret = (*env)->CallStatic##type##Method              \
                               (env, javaClass, jmethod);       \
	  else                                                  \
	    ret = (*env)->CallStatic##type##MethodA             \
                               (env, javaClass, jmethod, args); \
	}                                                       \
      else                                                      \
	{                                                       \
	  if (numberOfArgs == 0)                                \
	    ret = (*env)->Call##type##Method                    \
                               (env, jrcv, jmethod);            \
	  else                                                  \
	    ret = (*env)->Call##type##MethodA                   \
                               (env, jrcv, jmethod, args);      \
	}                                                       

/*
 * Checking exceptions after calling the method
 */

#define CHECK_JAVA_EXCEPTION(fail_return)                       \
      if ((*env)->ExceptionCheck (env))                         \
        {                                                       \
	  (*env)->PopLocalFrame (env, NULL);                    \
	  JIGSRaiseNSExceptionFromJException (env);             \
	  return (fail_return);                                 \
	}

#define CHECK_JAVA_EXCEPTION_NO_POP(fail_return)                \
      if ((*env)->ExceptionCheck (env))                         \
        {                                                       \
	  JIGSRaiseNSExceptionFromJException (env);             \
	  return (fail_return);                                 \
	}


/*
 *
 * THE REAL FORWARDING FUNCTIONS
 *
 */


// IMP for jboolean
jboolean _JIGS_jboolean_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jboolean ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types; 
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;
  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Boolean);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jbyte
jbyte _JIGS_jbyte_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jbyte ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types; 
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Byte);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jchar
jchar _JIGS_jchar_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jchar ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Char);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jshort
jshort _JIGS_jshort_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jshort ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Short);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jint
jint _JIGS_jint_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jint ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Int);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jlong
jlong _JIGS_jlong_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jlong ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Long);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jfloat
jfloat _JIGS_jfloat_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jfloat ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Float);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for jdouble
jdouble _JIGS_jdouble_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  jdouble ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  RUN_JAVA_METHOD(Double);
  CHECK_JAVA_EXCEPTION_NO_POP(0);
  
  return ret;
}

// IMP for void
void _JIGS_void_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type; 
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  CHECK_THE_TABLE_NO_RETURN;
  LOCK_THE_TABLE;
  CHECK_UNLOCK_NO_RETURN (_JIGS_selIDTable->classCount == 0, 
			  MESSAGE_SELIDTABLE_0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK_NO_RETURN (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK_NO_RETURN (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE);

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  CHECK_UNLOCK_NO_RETURN (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE);
  UNLOCK_THE_TABLE;

  GET_RECEIVER;

  PROCESS_ARGS;
  
  if (class_isMetaClass (class))
    {
      // Static method
      if (numberOfArgs == 0)
	{
	  (*env)->CallStaticVoidMethod (env, javaClass, jmethod);
	}
      else
	{
	  (*env)->CallStaticVoidMethodA (env, javaClass, jmethod, args);
	}
    }
  else // Instance method
    {
      if (numberOfArgs == 0)
	{
	  (*env)->CallVoidMethod (env, jrcv, jmethod);
	}
      else
	{
	  (*env)->CallVoidMethodA (env, jrcv, jmethod, args);
	}
    }

  if ((*env)->ExceptionCheck (env))                         
    {
      JIGSRaiseNSExceptionFromJException (env);           
    }
}

// IMP for jobject
id _JIGS_id_IMP_JavaMethod (id rcv, SEL sel, ...)
{
  const char *type;
  Class class = object_getClass (rcv);
  jclass javaClass = NULL;
  jmethodID jmethod = NULL;
  int i;
  int k;
  struct _JIGSSelectorIDEntry *classTable = _JIGS_selIDTable->classTable;
  int numberOfArgs;
  va_list ap;
  jvalue *args;
  jobject jrcv = NULL;
  JNIEnv *env = JIGSJNIEnv ();

  BOOL isConstructor;
  jobject ret;
  id objc_ret;

  CHECK_THE_TABLE;
  LOCK_THE_TABLE;
  CHECK_UNLOCK (_JIGS_selIDTable->classCount == 0, MESSAGE_SELIDTABLE_0, 0);

  k = find_class_in_selIDTable (class);
  CHECK_UNLOCK (k == -1, MESSAGE_CLASS_NOT_IN_SELIDTABLE, 0);

  javaClass = classTable[k].javaClass;
  CHECK_UNLOCK (javaClass == NULL, MESSAGE_NULL_CLASS_IN_SELIDTABLE, 0);  

  i = find_selector_in_selIDTable (k, sel);
  jmethod = classTable[k].selIDTable[i].methodID;
  numberOfArgs = classTable[k].selIDTable[i].numberOfArgs;   
  type = classTable[k].selIDTable[i].types;
  // isConstructor is only possible for methods returning objects
  isConstructor = classTable[k].selIDTable[i].isConstructor;
  CHECK_UNLOCK (jmethod == NULL, MESSAGE_SELECTOR_NOT_IN_SELIDTABLE, 0);
  UNLOCK_THE_TABLE;

  PROCESS_ARGS;
  
  //
  // A constructor is extremely special. 
  //
  if (isConstructor == YES)
    {
      jobject tmpObject;
      
      if ((*env)->PushLocalFrame (env, 1) < 0)
	{
	  JIGSRaiseNSExceptionFromJException (env);
	  return 0; 
	}
      
      if (numberOfArgs == 0)
	{
	  tmpObject = (*env)->NewObject (env, javaClass, jmethod);
	}
      else
	{
	  tmpObject = (*env)->NewObjectA (env, javaClass, jmethod, args);
	}
      
      CHECK_JAVA_EXCEPTION(0);

      ((_java_lang_Object *)rcv)->realObject = (*env)->NewGlobalRef 
	(env, tmpObject);

      if (((_java_lang_Object *)rcv)->realObject == NULL)
	{
	  (*env)->PopLocalFrame (env, NULL);
	  JIGSRaiseNSExceptionFromJException (env);
	  return 0;
	}
      
      (*env)->PopLocalFrame (env, NULL);
      
      _JIGSMapperAddObjcProxy (env, ((_java_lang_Object *)rcv)->realObject, 
			       rcv);
      return rcv;
    }

  // Else, it is not a constructor
  GET_RECEIVER; 

  // We need a reference (the returned object)
  if ((*env)->PushLocalFrame (env, 1) < 0)
    {
      JIGSRaiseNSExceptionFromJException (env);
      return 0; 
    }
  RUN_JAVA_METHOD(Object);
  CHECK_JAVA_EXCEPTION(0);

  objc_ret = JIGSIdFromJobject (env, ret);
  (*env)->PopLocalFrame (env, NULL);
  return objc_ret;
}

/*
 * Clean macro space.
 */

#undef CHECK_THE_TABLE
#undef CHECK_THE_TABLE_NO_RETURN
#undef LOCK_THE_TABLE 
#undef UNLOCK_THE_TABLE 
#undef CHECK_UNLOCK
#undef CHECK_UNLOCK_NO_RETURN
#undef MESSAGE_SELIDTABLE_NULL 
#undef MESSAGE_SELDITABLE_0
#undef MESSAGE_CLASS_NOT_IN_SELIDTABLE
#undef MESSAGE_NULL_CLASS_IN_SELIDTABLE
#undef MESSAGE_SELECTOR_NOT_IN_SELIDTABLE
#undef GET_RECEIVER 
#undef INIT_PROCESS_ARGS              
#undef DO_PROCESS_ARGS                 
#undef END_PROCESS_ARGS 
#undef PROCESS_ARGS
#undef RUN_JAVA_METHOD
#undef CHECK_JAVA_EXCEPTION
#undef CHECK_JAVA_EXCEPTION_NO_POP

