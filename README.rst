Quickstart
==========

Run `try` and hopefully you'll see a huge list of headers spewed out.


Contribute
==========

Clang needs these kinds of minimal tutorials. If you try this out, fork the
repo! Then if you make something even remotely interesting, send me a pull
request and I'll add it to the collection (obviously I'll then need to
organize things better).

Some ideas:

* Add a RecursiveASTVisitor and scrape interesting statistics about your
  program (i.e. how many while loops are there in a source file?). You'll
  need a custom ASTConsumer that hands off to the RecursiveASTVisitor.
  Check the doxygen.

* Inject the FindDependencies plugin into the build of a project (why not
  LLVM/Clang?) then run some graph algorithms on the result.
