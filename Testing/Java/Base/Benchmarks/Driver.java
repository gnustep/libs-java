/* Driver: driver running benchmarks

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: November 2001
   
   This file is part of GNUstep.
   
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

class Driver
{
  static int warmUpIterations = 5000;
  static int iterations = 1000000;
  static double baseline;

  public static void main (String[] args) 
    throws Throwable
  {
    System.out.println ("== Initializing ==");
    System.out.println ("Running loops of " + iterations + " iterations.");
    System.out.println ("Trying how much it takes to run an empty loop ... ");
    /* Run it five times to make sure we warm up.   */
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    System.out.println ("It takes " + baseline + " milliseconds.");
    System.out.println ("We will silently remove this time from all benchmarks.");

    System.out.println ("\n== Note on the benchmarks ==");
    System.out.println ("The number displayed after each benchmark is the number of milliseconds");
    System.out.println ("required to perform that operation " + iterations 
			+ " times.");
    System.out.println ("The time taken to perform the loop has already been taken account for.");
    System.out.println ("A star (*) after a number means we really run only "
			+ (int)(iterations/10));
    System.out.println ("iterations and multiplied the resulting time by 10.");
    System.out.println ("Results with a star (*) are much less precise.");
    System.out.println ("\n== Running benchmarks ==");

    /* 
     * Basic Java benchmarks to get the feeling.  
     */
    System.out.println ("<* Basic Java benchmarks *>");

    /* Integers, arrays.  */
    runLoopAndPrintResult (new ArrayBenchmark ());

    /* Strings.  */
    runLoopAndPrintResult (new StringConcatenationBenchmark ());
    runLoopAndPrintResult (new StringComparisonBenchmark ());

    /*
     * Methods, Java vs ObjC.
     */
    System.out.println ("<* Direct method invocations *>");

    /* Method invocations.  */
    runLoopAndPrintResult (new JavaMethodBenchmark ());
    runLoopAndPrintResult (new ObjCMethodBenchmark ());

    /* Constructors.  */
    runLoopAndPrintResult (new JavaNewObjectBenchmark ());
    runShortLoopAndPrintResult (new ObjCNewObjectBenchmark ());

    /* Descriptions.  */
    runShortLoopAndPrintResult (new JavaToStringBenchmark ());
    runShortLoopAndPrintResult (new ObjCToStringBenchmark ());

    /*
     *  NSMutableArray vs Vector.  
     */
    System.out.println ("<* NSMutableArray *>");
    runShortLoopAndPrintResult (new NSArray0Benchmark ());
    runShortLoopAndPrintResult (new NSArray1Benchmark ());
    runShortLoopAndPrintResult (new NSArray2Benchmark ());
    runShortLoopAndPrintResult (new NSArray3Benchmark ());
    runShortLoopAndPrintResult (new NSArray4Benchmark ());
    runShortLoopAndPrintResult (new NSArray5Benchmark ());
    runLoopAndPrintResult (new NSArray6Benchmark ());
    runShortLoopAndPrintResult (new NSArray7Benchmark ());

    System.out.println ("<* Vector *>");
    runLoopAndPrintResult (new Vector0Benchmark ());
    runLoopAndPrintResult (new Vector1Benchmark ());
    runLoopAndPrintResult (new Vector2Benchmark ());
    runLoopAndPrintResult (new Vector3Benchmark ());
    runLoopAndPrintResult (new Vector4Benchmark ());
    runLoopAndPrintResult (new Vector5Benchmark ());
    runLoopAndPrintResult (new Vector6Benchmark ());
    runLoopAndPrintResult (new Vector7Benchmark ());

  }

  static void runShortLoopAndPrintResult (Benchmark b)
  {
    /* Try to remove garbage.  */
    System.gc ();

    /* Warm up.  */
    runWarmUpLoop (b);

    /* Now run the real loop.  */
    double time = (runShortLoop (b) * 10) - baseline;
    System.out.println (" " + b.name () + ": " + (int)time + "(*)");

    /* Try to remove garbage.  */
    System.gc ();
  }

  static void runLoopAndPrintResult (Benchmark b)
  {
    /* Try to remove garbage.  */
    System.gc ();

    /* Warm up.  */
    runWarmUpLoop (b);

    /* Now run the real loop.  */
    double time = runLoop (b) - baseline;
    System.out.println (" " + b.name () + ": " + (int)time);

    /* Try to remove garbage.  */
    System.gc ();
  }

  static double runWarmUpLoop (Benchmark b)
  {
    double start, stop;
    int i;
    Object unused;

    start = System.currentTimeMillis ();

    for (i = 0; i < warmUpIterations; i++)
      {
	unused = b.executeBasicOperation ();
      }
    
    stop = System.currentTimeMillis ();

    return (stop - start);
  }

  static double runShortLoop (Benchmark b)
  {
    double start, stop;
    int i;
    Object unused;

    int j = (int)(iterations / 10);

    start = System.currentTimeMillis ();

    for (i = 0; i < j; i++)
      {
	unused = b.executeBasicOperation ();
      }
    
    stop = System.currentTimeMillis ();

    return (stop - start);
  }

  static double runLoop (Benchmark b)
  {
    double start, stop;
    int i;
    Object unused;

    start = System.currentTimeMillis ();

    for (i = 0; i < iterations; i++)
      {
	unused = b.executeBasicOperation ();
      }
    
    stop = System.currentTimeMillis ();

    return (stop - start);
  }
}
