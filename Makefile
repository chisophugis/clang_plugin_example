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

WARN ?= -Wall -Wextra -Weffc++ -pedantic
CXXFLAGS += -std=c++11 -fPIC $(WARN) $(shell $(LLVM_CONFIG) --cxxflags)
CPPFLAGS += -I$(LLVM_INCLUDE_DIR) -I$(CLANG_INCLUDE_DIR)

# Darwin requires different linker flags.
OS ?= $(shell uname)
LDFLAGS += $(shell $(LLVM_CONFIG) --ldflags)
ifeq ($(OS),Darwin)
  LDFLAGS += -Wl,-undefined,dynamic_lookup
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
endif

MODULE_NAME := FindDependencies
OBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))


# first rule, built by default
$(MODULE_NAME).so: $(OBJS)

# -o $@ $< must come *before*
%.so: $(OBJS)
	$(CXX) -shared -o $@ $^ $(LDFLAGS)


%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(MODULE_NAME).so $(OBJS)
