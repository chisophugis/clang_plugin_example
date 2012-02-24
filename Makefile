CXX := clang++
WARN ?= -Wall -Wextra -Weffc++ -pedantic -std=c++11
CXXFLAGS += -fPIC $(WARN) $(shell llvm-config --cxxflags)

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
