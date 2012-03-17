# This file uses features of GNU Make that other make programs don't have.

# Handle binaries and libraries outside the normal paths.
PREFIX ?= /usr
CXX := $(PREFIX)/bin/clang++
LLVM_CONFIG := $(PREFIX)/bin/llvm-config

WARN ?= -Wall -Wextra -Weffc++ -pedantic
CXXFLAGS += -std=c++11 -fPIC $(WARN) $(shell $(LLVM_CONFIG) --cxxflags)

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

LDFLAGS += $(shell llvm-config --ldflags) $(CLANG_LIBS)


MODULE_NAME := FindDependencies
OBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))


# first rule, built by default
$(MODULE_NAME).so: $(OBJS)

# -o $@ $< must come *before*
%.so: $(OBJS)
	$(CXX) -shared -o $@ $^ $(LDFLAGS)


%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -f $(MODULE_NAME).so $(OBJS)
