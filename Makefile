# This file uses features of GNU Make that other make programs don't have.

# Handle binaries and libraries outside the normal paths.
PREFIX ?= /usr
CXX := $(PREFIX)/bin/clang++
LLVM_CONFIG := $(PREFIX)/bin/llvm-config

# If building using an llvm/clang source checkout:
#   export LLVM_INCLUDE_DIR=???/llvm/include
#   export CLANG_INCLUDE_DIR=???/llvm/tools/clang/include
# before calling make.
LLVM_INCLUDE_DIR ?= $(PREFIX)/share/include
CLANG_INCLUDE_DIR ?= $(PREFIX)/share/include

# If building using an llvm/clang source checkout:
#   export LLVM_LIB_DIR=???/llvm/Debug+Asserts/lib
#   export CLANG_LIB_DIR="$LLVM_LIB_DIR"
# before calling make.
LLVM_LIB_DIR ?= $(PREFIX)/lib
CLANG_LIB_DIR ?= $(PREFIX)/lib

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
OBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))


# first rule, built by default
$(MODULE_NAME).$(SO): $(OBJS)

%.$(SO): $(OBJS)
# -o $@ $< must come *before*
	$(CXX) -shared -o $@ $^ $(LDFLAGS)


%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	-rm -f $(MODULE_NAME).$(SO) $(OBJS)
