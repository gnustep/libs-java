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
  static int warmUpIterations = 2000;
  static int iterations = 100000;
  static double baseline;

  public static void main (String[] args) 
    throws Throwable
  {
    if (args.length < 1)
      {
	System.out.println ("Usage: Driver <BenchmarkName>");
	System.exit (1);
      }
    

    /* First determine how long it takes an empty loop.  */

    /* Run it five times to make sure we warm up.   */
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    baseline = runLoop (new EmptyBenchmark ());
    /* It takes baseline milliseconds.  */

    /* We will silently remove this time from all benchmarks.  */

    Class benchmark = Class.forName (args[0]);
    runLoopAndPrintResult ((Benchmark)(benchmark.newInstance ()));
  }

  static void runLoopAndPrintResult (Benchmark b)
  {
    /* Try to remove garbage.  */
    System.gc ();

    /* Warm up.  */
    runWarmUpLoop (b);

    /* Now run the real loop.  */
    double time = runLoop (b) - baseline;
    if (time < 0)
      {
	time = 0;
      }
    System.out.println (" " + b.name () + ": " + (int)time);

    /* Try to remove garbage.  */
    System.gc ();
  }

  static double runWarmUpLoop (Benchmark b)
  {
    double start, stop;
    int i;
    Object unused;

    System.gc ();
    System.gc ();
    System.gc ();

    start = System.currentTimeMillis ();

    for (i = 0; i < warmUpIterations; i++)
      {
	unused = b.executeBasicOperation ();
      }
    
    System.gc ();
    System.gc ();
    System.gc ();

    stop = System.currentTimeMillis ();

    return (stop - start);
  }

  static double runLoop (Benchmark b)
  {
    double start, stop;
    int i;
    Object unused;

    System.gc ();
    System.gc ();
    System.gc ();

    start = System.currentTimeMillis ();

    for (i = 0; i < iterations; i++)
      {
	unused = b.executeBasicOperation ();
      }

    /* Garbaging collecting the objects created is part of the test
       and must be measured.  */
    System.gc ();
    System.gc ();
    System.gc ();
    
    stop = System.currentTimeMillis ();

    return (stop - start);
  }
}
