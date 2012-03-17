# This file uses features of GNU Make that other make programs don't have.

# Handle binaries and libraries outside the normal paths.
# If building using an llvm/clang source checkout:
#   export PREFIX="???/Debug+Asserts/"
# before calling make, and LLVM_LIB_DIR and CLANG_LIB_DIR should take care
# of themselves.
PREFIX ?= /usr

# Binaries, by default under PREFIX.
CXX := $(PREFIX)/bin/clang++
LLVM_CONFIG := $(PREFIX)/bin/llvm-config

# Library directories, by default under PREFIX.
LLVM_LIB_DIR ?= $(PREFIX)/lib
CLANG_LIB_DIR ?= $(LLVM_LIB_DIR)

# If building using an llvm/clang source checkout:
#   export LLVM_INCLUDE_DIR=???/llvm/include
#   export CLANG_INCLUDE_DIR=???/llvm/tools/clang/include
# before calling make.
LLVM_INCLUDE_DIR ?= $(PREFIX)/share/include
CLANG_INCLUDE_DIR ?= $(LLVM_INCLUDE_DIR)

# This will complain about a bunch of unused args in the clang headers.
WARN ?= -Wall -Wextra -Weffc++ -pedantic
CXXFLAGS += -std=c++11 -fPIC $(WARN) $(shell $(LLVM_CONFIG) --cxxflags)
CPPFLAGS += -I$(LLVM_INCLUDE_DIR) -I$(CLANG_INCLUDE_DIR)

# Darwin requires different linker flags.
OS ?= $(shell uname)
LDFLAGS += $(shell $(LLVM_CONFIG) --ldflags) \
           -L$(LLVM_LIB_DIR) -L$(CLANG_LIB_DIR)
ifeq ($(OS),Darwin)
  LDFLAGS += -Wl,-undefined,dynamic_lookup
  SO = dylib
else
  CLANG_LIBS := -lclangFrontend \
                -lclangParse \
                -lclangSema \
                -lclangAnalysis \
                -lclangAST \
                -lclangLex \
                -lclangBasic \
                -lclangDriver \
                -lclangSerialization \
                -lLLVMMC \
                -lLLVMSupport
  LDFLAGS += $(CLANG_LIBS)
  SO = so
endif

MODULE_NAME := FindDependencies
PLUGIN_NAME := find-deps
OBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))

# Build plugin loading flags in CC1_OPTS.
# These look like -Xclang -load -Xclang mod.so -Xclang -plugin -Xclang mod
# followed by, for each arg, -Xclang -plugin-arg-mod -Xclang arg.
#
# To pass args to the plugin, export PLUGIN_ARGS="your args here"
# before running make.
PLUGIN_OPTS := -load $(MODULE_NAME).$(SO) -plugin $(PLUGIN_NAME)
CC1_OPTS := $(addprefix -Xclang ,$(PLUGIN_OPTS))

# If we have any plugin args, mangle them for the clang++ invocation and
# append to CC1_OPTS.
ifneq ($(strip $(PLUGIN_ARGS)),)
  PLUGIN_FLAG := -plugin-arg-$(MODULE_NAME)
  CC1_OPTS += $(addprefix -Xclang ,$(addprefix $(PLUGIN_FLAG) ,$(PLUGIN_ARGS)))
endif

.DEFAULT_GOAL: demo
.PHONY: demo
demo: $(MODULE_NAME).$(SO)
# Having every bunch of flags on a separate line makes it easier to work out
# what's going on when make echoes the command.
	$(CXX) \
	  $(CC1_OPTS) \
	  $(CPPFLAGS) \
	  $(CXXFLAGS) \
	  $(LDFLAGS) \
	  "$(MODULE_NAME).cpp"
	test -f a.out
	test -x a.out

$(MODULE_NAME).$(SO): $(OBJS)

%.$(SO): $(OBJS)
# -o $@ $< must come *before*
	$(CXX) -shared -o "$@" $^ $(LDFLAGS)


%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o "$@" $<

.PHONY: clean
clean:
	-rm -f $(MODULE_NAME).$(SO)
	-rm -f $(OBJS)
	-rm -f a.out
ifeq ($(OS),Darwin)
	-rm -rf a.out.dSYM
endif
