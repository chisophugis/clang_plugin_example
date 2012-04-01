#include "clang/AST/ASTConsumer.h"
#include "clang/Basic/FileManager.h"
#include "clang/Basic/SourceManager.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendPluginRegistry.h"
#include "clang/Lex/PPCallbacks.h"
#include "clang/Lex/Preprocessor.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/raw_ostream.h"

#include <string>
#include <vector>

using namespace clang;

namespace {


// Adapted from Douglas Gregor's presentation (slide 8):
// http://llvm.org/devmtg/2011-11/Gregor_ExtendingClang.pdf
class FindDependencies : public PPCallbacks {
  SourceManager& SM;
 public:

  explicit FindDependencies(SourceManager& sm) : SM(sm) { }

  void FileChanged(SourceLocation Loc,
                   FileChangeReason Reason,
                   SrcMgr::CharacteristicKind, FileID) {
    if (Reason != EnterFile)
      return;
    if (const FileEntry *FE = SM.getFileEntryForID(SM.getFileID(Loc)))
      llvm::outs() << ">>> Depends on " << FE->getName() << " <<<\n";
  }

};


// This class is "the plugin". Plugins work by overriding methods of the
// PluginASTAction class that are called over the course of compilation.
// Check the doxygen docs for the class hierarchy of PluginASTAction to
// find all the methods that are overridable. BeginSourceFileAction is
// probably the most interesting.
class FindDependenciesAction : public PluginASTAction {

  // We must override this since it is pure virtual in PluginASTAction.
  // We just return a dummy ASTConsumer. If you have a custom ASTConsumer
  // that you want to run on the AST, then you may return it here instead.
  ASTConsumer *CreateASTConsumer(CompilerInstance &, llvm::StringRef) {
    return new ASTConsumer;
  }

  bool ParseArgs(const CompilerInstance &,
                 const std::vector<std::string>& args);

  bool BeginSourceFileAction(CompilerInstance& CI, llvm::StringRef);
};


// This is where the action happens. By modifying the CompilerInstance, you
// can access most of the interesting stuff that Clang does.
bool FindDependenciesAction::BeginSourceFileAction(CompilerInstance& CI,
                                                   llvm::StringRef) {
  Preprocessor &PP = CI.getPreprocessor();
  PP.addPPCallbacks(new FindDependencies(CI.getSourceManager()));
  return true;
}


// We aren't doing much with this right now, but it's nice to have it at
// arm's length.
bool FindDependenciesAction::ParseArgs(const CompilerInstance &,
                                       const std::vector<std::string>& args) {
  for (unsigned i = 0, e = args.size(); i != e; ++i)
    llvm::outs() << "Received arg: " << args[i] << "\n";
  return true;
}


} // anonymous namespace


static FrontendPluginRegistry::Add<FindDependenciesAction>
X("find-deps", "Print out header dependencies");
