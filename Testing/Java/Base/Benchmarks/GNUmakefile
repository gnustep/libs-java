#  GNUmakefile for the JIGS's Java Benchmarks
#
#  Copyright (C) 2001 Free Software Foundation, Inc.
#
#  Author:  Nicola Pero <n.pero@mi.flashnet.it>
#  Date: November 2001
#   
#  This file is part of GNUstep.
#   
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#   
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#   
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

include $(GNUSTEP_MAKEFILES)/common.make

JAVA_PACKAGE_NAME = gnu.gnustep.base-benchmark
gnu.gnustep.base-benchmark_JAVA_FILES =       \
    Driver.java                               \
    Benchmark.java                            \
    EmptyBenchmark.java                       \
    SecondaryThreadBenchmark.java             \
    ArrayBenchmark.java                       \
    StringConcatenationBenchmark.java         \
    StringComparisonBenchmark.java            \
    ObjCMethodBenchmark.java                  \
    ObjCMethodSecondThreadBenchmark.java      \
    JavaMethodBenchmark.java                  \
    JavaNewObjectBenchmark.java               \
    ObjCNewObjectBenchmark.java               \
    ObjCNewObjectSecondThreadBenchmark.java   \
    JavaToStringBenchmark.java                \
    ObjCToStringBenchmark.java                \
    ObjCToStringSecondThreadBenchmark.java    \
    NSArray0Benchmark.java                    \
    NSArray1Benchmark.java                    \
    NSArray2Benchmark.java                    \
    NSArray3Benchmark.java                    \
    NSArray4Benchmark.java                    \
    NSArray5Benchmark.java                    \
    NSArray6Benchmark.java                    \
    NSArray7Benchmark.java                    \
    Vector0Benchmark.java                     \
    Vector1Benchmark.java                     \
    Vector2Benchmark.java                     \
    Vector3Benchmark.java                     \
    Vector4Benchmark.java                     \
    Vector5Benchmark.java                     \
    Vector6Benchmark.java                     \
    Vector7Benchmark.java

include $(GNUSTEP_MAKEFILES)/java.make

benchmark:: all
	./benchmark-base



