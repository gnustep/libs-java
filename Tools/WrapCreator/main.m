/* main.m: Main body of Wrap Creator -*-objc-*-

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

#include <Foundation/Foundation.h>
#include "WCLibrary.h"

static void print_warning_and_exit (NSString *message)
{
  NSLog (message);
  exit (1);
}

static void print_help_and_exit ()
{
  printf ("This is JIGS WrapCreator.\n");
  printf ("Usage: WrapCreator [options]\n");
  printf (" `options' might be:\n");
  printf ("  --help: print this message;\n");
  printf ("  --jigs-file filename: read wrap preferences from filename\n");
  printf ("                        filename should be in the appropriate format\n");
  printf ("  --wrapper-dir directory: use directory as the top wrapper dir\n");
  printf ("  --preprocessed-header filename: use filename as the preprocessed\n");
  printf ("                                  header\n");
  printf ("  --no-verbose: do not output information on what it is doing\n");
  printf ("  --silent: same as --no-verbose\n");
  printf ("  --verbose: output information as we go on (this is the default)\n");
  printf ("Please note that usually this tool should be run automatically\n");
  printf (" by the GNUstep make package\n");
  exit (0);
}

static void print_version_and_exit ()
{
  printf ("This is JIGS WrapCreator.\n");
  // TODO - print the version
  exit (0);
}

int main (int argc, char **argv, char **env)
{
  NSAutoreleasePool *pool;
  NSArray *args;
  NSString *key, *value;
  NSString *jigs_file = nil;
  NSString *wrapper_dir = nil;
  NSString *preprocessed_header = nil;
  NSString *library_name = nil;
  NSString *library_header = nil;
  BOOL verbose_output = YES;
  int i, count;

#if LIB_FOUNDATION_LIBRARY
  [NSProcessInfo initializeWithArguments: argv  count: argc  environment: env];
  [NSAutoreleasePool enableDoubleReleaseCheck:YES];
#endif

  pool = [NSAutoreleasePool new];
  args = [[NSProcessInfo processInfo] arguments];
  
  count = [args count];

  for (i = 0; i < count; i++)
    {
      key = [args objectAtIndex: i]; 
      if ([key isEqualToString: @"--help"]) 
	{
	  print_help_and_exit ();
	}
      if ([key isEqualToString : @"--version"])
	{
	  print_version_and_exit ();	  
	}
      if ([key isEqualToString: @"--jigs-file"])
	{
	  if ((i + 1) < count)
	    {
	      i++;
	      value = [args objectAtIndex: i];
	      ASSIGN (jigs_file, value);
	      continue;
	    }
	  else
	    {
	      print_warning_and_exit 
		(@"missing argument to the --jigs-file option"); 
	    }
	}
      if ([key isEqualToString: @"--wrapper-dir"])
	{
	  if ((i + 1) < count)
	    {
	      i++;
	      value = [args objectAtIndex: i];
	      ASSIGN (wrapper_dir, value);
	      continue;
	    }
	  else
	    {
	      print_warning_and_exit 
		(@"missing argument to the --wrapper-dir option"); 
	    }
	}
      if ([key isEqualToString: @"--preprocessed-header"])
	{
	  if ((i + 1) < count)
	    {
	      i++;
	      value = [args objectAtIndex: i];
	      ASSIGN (preprocessed_header, value);
	      continue;
	    }
	  else
	    {
	      print_warning_and_exit 
		(@"missing argument to the --preprocessed-header option"); 
	    }
	}
      if ([key isEqualToString: @"--library-name"])
	{
	  if ((i + 1) < count)
	    {
	      i++;
	      value = [args objectAtIndex: i];
	      ASSIGN (library_name, value);
	      continue;
	    }
	  else
	    {
	      print_warning_and_exit 
		(@"missing argument to the --library-name option"); 
	    }
	}
      if ([key isEqualToString: @"--library-header"])
	{
	  if ((i + 1) < count)
	    {
	      i++;
	      value = [args objectAtIndex: i];
	      ASSIGN (library_header, value);
	      continue;
	    }
	  else
	    {
	      print_warning_and_exit 
		(@"missing argument to the --library-header option"); 
	    }
	}
      if ([key isEqualToString: @"--verbose"])
	{
	  verbose_output = YES;
	}
      if ([key isEqualToString: @"--no-verbose"])
	{
	  verbose_output = NO;
	}
      if ([key isEqualToString: @"--silent"])
	{
	  verbose_output = NO;
	}
    }


  if (jigs_file == nil)
    {
      // TODO: Look for any *.jigs file in the directory and use that one.
      print_warning_and_exit (@"missing compulsory option --jigs-file"); 
    }

  if (wrapper_dir == nil)
    {
      wrapper_dir = @"JavaWrapper";
    }

  if (preprocessed_header == nil)
    {
      preprocessed_header = [NSString stringWithFormat: @"%@/preprocessedHeader",
				      wrapper_dir];
    }

  if (library_name == nil)
    {
      // TODO: Look in the jigs file and get the name from there
      print_warning_and_exit (@"missing compulsory option --library-name"); 
    }

  if (library_header == nil)
    {
      // TODO: Look in the jigs file and get the name from there
      print_warning_and_exit (@"missing compulsory option --library-header"); 
    }

  [WCLibrary initializeWithJigsFile: jigs_file
	     preprocessedHeaderFile: preprocessed_header
	     headerFile: library_header
	     wrapDirectory: wrapper_dir
	     libraryName: library_name
	     verboseOutput: verbose_output];

  [WCLibrary outputWrappers];

  RELEASE (pool);
  return 0;
}

