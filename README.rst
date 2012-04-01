Quickstart
==========

Run ``make demo`` and hopefully you'll see a huge list of headers spewed
out.  If that didn't work, contact me (chisophugis@gmail.com) immediately
and I will fix it.


Goal
====

The goal of this is to be a really clear and simple tutorial on how to do
useful stuff with clang. I'm hoping it will make a good "Hello World" for
people new to clang; that's exactly what I found most sorely lacking
documentation-wise for clang (and LLVM in general), and my experience was
so distasteful that I feel impelled to fix the situation.

However, the doxygen docs are fantastic! Once you make it past the inital
hurdle of the "Hello World", it's pretty smooth sailing. I find that
googling "clang SomeClass" will usually have the doxygen documentation as
the first hit.


Improvements
============

Contact me immediately if

* you have any trouble whatsoever with this example program

* find anything insufficiently explained (even the Makefile!)

* find any explanations unclear

* you come up with a small tweak that could make the program more
  interesting

* have a suggestion for something that you would like to see the program do
  that you think would make an interesting "Hello World"


Contribute
==========

Clang needs these kinds of minimal tutorials to get people up and running
quickly. If you try this out, fork the repo! Then if you make something
even remotely interesting that helped you learn some part of clang, send me
a message and we'll see if we can distill a nice simple example plugin out
of it and add it to the collection (obviously I'll organize things better
if that happens).

Some ideas:

* Add a ``RecursiveASTVisitor`` and scrape interesting statistics about
  your program (i.e. how many while loops are there in a source file?).
  You'll need a custom ``ASTConsumer`` that hands off to the
  ``RecursiveASTVisitor``.  Check the doxygen.

* Inject the ``FindDependencies`` plugin into the build of a project (why
  not LLVM/Clang?) then run some graph algorithms on the result.
