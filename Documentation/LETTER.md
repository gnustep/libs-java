# Java Was Strongly Influenced by Objective-C and not C++...

A while back, the following posting was made by Patrick Naughton who, along with James Gosling, was responsible for much of the design of . Objective-C is an object-oriented mutant of C used NeXTSTEP and MacOS X, and also available with gcc.

Tom Gall  wrote:
> Sean Luke wrote:
>> Blair MacIntyre (bm@renoir.cs.columbia.edu) wrote:

>>> BZZT.  Wrong.  Java was modelled on a number of languages, most
>>> importantly Modula-3 and C++.

>> Of course, it's nonsense that Java was modelled off of NewtonScript,
>> but it's even goofier to say that Java was based on Modula-3 and C++.

>> Java's *syntax* may resemble C++, but it has no similarity to C++
>> as a language. Java's chief *semantics* are dynamically-bound and
>> use single inheritance, class objects, and an extensive runtime system.
>> C++ and Modula-3 are as far away from this model as any object-oriented
>> language can be.

>> Java is clearly semantically derivative of Smalltalk and other
>> languages related to it. Most notably, NeXT's
>> Objective-C is almost uncannily similar to Java: single inheritance,
>> dynamic binding, dynamic loading, "class" objects, interfaces,
>> and now methods stored as data (a-la Java's "reflection" library),
>> all-virtual functions, you name it.  It's almost weird.

> Hardly weird it was by design actually. As I remember my Java history
> Patrick Naughton the gentleman who got the ball rolling was about to
> quit Sun and join up with NeXT. He happened to be on the same
> intermural hockey team as Scott McNealy. Scott told him to hold off,
> write what he thought was wrong with Sun before he left. Patrick
> didn't leave and was one of the original Oak people. I would like
> to think his affinity for NeXTSTEP showed up in Java, with it
> having an close look and feel to that of Objective-C. (The main
> language on NeXTSTEP)

I don't generally read usenet any more (not since the good old days of
comp.graphics in the 80's...), but I happened across this article while I
was messing around with Excite Live... (a pretty cool service in
itself)...

As it turns out, Sean and Tom are both absolutely correct.  Usually, this
kind of urban legend stuff turns out to be completely inaccurate, but in
this case, they are right on.  When I left Sun to go to NeXT, I thought
Objective-C was the coolest thing since sliced bread, and I hated C++. 
So, naturally when I stayed to start the (eventually) Java project, Obj-C
had a big influence.  James Gosling, being much older than I was, he had
lots of experience with SmallTalk and Simula68,  which we also borrowed
from liberally.

The other influence, was that we had lots of friends working at NeXT at
the time, whose faith in the black cube was flagging.  Bruce Martin was
working on the NeXTStep 486 port, Peter King, Mike Demoney, and John
Seamons were working on the mysterious (and never shipped) NRW (NeXT RISC
Workstation, 88110???).  They all joined us in late '92 - early '93 after
we had written the first version of Oak.  I'm pretty sure that Java's
'interface' is a direct rip-off of Obj-C's 'protocol' which was largely
designed by these ex-NeXT'ers... Many of those strange primitive wrapper
classes, like Integer and Number came from Lee Boynton, one of the early
NeXT Obj-C class library guys who hated 'int' and 'float' types.

Another interesting side-note, (so as not to break any rules on my first
[and last]-ever posting to comp.sys.newton), John Seamons, (who happened
to be Andy Bechtolsheim's roommate at Stanford and largely reponsible for
the first ever port of Unix to the SUN-0) once did a port of Oak (Java)
to the Newton.	We were in the midst of trying to do a deal with 3DO to
run as their OS/API, and we didn't have any 3DO dev systems on hand, so
John took apart an Apple Newton 100 and wired it up to a bunch of logic
analyzers, reverse engineered the interfaces and actually got some of the
original Star7 demo to run on this machine.  After the 3DO deal tubed, I
think most of the code was lost to history...  last I heard, John was out
in Aspen working for wnj, so you never know.

Sigh... we sure knew how to have fun in those days...

-Patrick

-------------
Patrick Naughton
President and CTO
Starwave Corporation
http://www.starwave.com/people/naughton
