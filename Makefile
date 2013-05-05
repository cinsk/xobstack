
.PHONY: all clean rebuild

OBJS = xobstack.o

CC=gcc
CXX=g++
CFLAGS=-Wall -g -fPIC
CXXFLAGS=$(CFLAGS)

VERSION_MAJOR=0
VERSION_MINOR=1
LIBNAME=libxobs

DYLIBSUFFIX=so
STLIBSUFFIX=a
DYLIB_MINOR_NAME=$(LIBNAME).$(DYLIBSUFFIX).$(VERSION_MAJOR).$(VERSION_MINOR)
DYLIB_MAJOR_NAME=$(LIBNAME).$(DYLIBSUFFIX).$(VERSION_MAJOR)

DYLIBNAME=$(LIBNAME).$(DYLIBSUFFIX)
DYLIB_MAKE_CMD=$(CC) -shared -Wl,-soname,$(DYLIB_MINOR_NAME) \
	-o $(DYLIBNAME) $(LDFLAGS)
STLIBNAME=$(LIBNAME).$(STLIBSUFFIX)
STLIB_MAKE_CMD=ar rcs $(STLIBNAME)

TEST_LDFLAGS = -L. -Wl,-rpath=. -lxobs

# Platform-specific overrides
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
ifeq ($(uname_S),SunOS)
#  LDFLAGS +=
  DYLIB_MAKE_CMD=$(CC) -G -o $(DYLIBNAME) -h $(DYLIB_MINOR_NAME) $(LDFLAGS)
  INSTALL= cp -r
endif
ifeq ($(uname_S),Darwin)
  DYLIBSUFFIX=dylib
  DYLIB_MINOR_NAME=$(LIBNAME).$(VERSION_MAJOR).$(VERSION_MINOR).$(DYLIBSUFFIX)
  DYLIB_MAJOR_NAME=$(LIBNAME).$(VERSION_MAJOR).$(DYLIBSUFFIX)
  DYLIB_MAKE_CMD=$(CC) -shared -Wl,-install_name,$(DYLIB_MINOR_NAME) -o $(DYLIBNAME) $(LDFLAGS)
  TEST_LDFLAGS = -L. -Xlinker -rpath -Xlinker . -lxobs
endif


all: $(DYLIBNAME) test-c test-cxx
rebuild: clean all

$(OBJS): %.o: %.c %.h
	$(CC) -c $(CFLAGS) -o $@ $<

$(DYLIBNAME): $(OBJS)
	$(DYLIB_MAKE_CMD) $(OBJS)

$(STLIBNAME): $(OBJS)
	$(STLIB_MAKE_CMD) $(OBJS)

test-cxx.o: test-cxx.cc
	$(CXX) -c $(CXXFLAGS) test-cxx.cc

test-c.o: test-c.c
	$(CC) -c $(CFLAGS) test-c.c

test-cxx: test-cxx.o $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) \
		-o test-cxx test-cxx.o $(TEST_LDFLAGS)

test-c: test-c.o $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) \
		-o test-c test-c.o $(TEST_LDFLAGS)

clean:
	rm -f test-c test-cxx
	rm -f $(OBJS)

# Installation related variables and target
PREFIX?=/usr/local
INCLUDE_DIR?=include
LIBRARY_DIR?=lib
INSTALL_INCLUDE_PATH=$(PREFIX)/$(INCLUDE_DIR)
INSTALL_LIBRARY_PATH=$(PREFIX)/$(LIBRARY_DIR)

ifeq ($(uname_S),SunOS)
  INSTALL?= cp -r
endif

INSTALL?= cp -a

install: $(DYLIBNAME) $(STLIBNAME)
	mkdir -p $(INSTALL_INCLUDE_PATH) $(INSTALL_LIBRARY_PATH)
	$(INSTALL) xobstack.h $(INSTALL_INCLUDE_PATH)
	$(INSTALL) $(DYLIBNAME) $(INSTALL_LIBRARY_PATH)/$(DYLIB_MINOR_NAME)
	cd $(INSTALL_LIBRARY_PATH) && \
		ln -sf $(DYLIB_MINOR_NAME) $(DYLIB_MAJOR_NAME)
	cd $(INSTALL_LIBRARY_PATH) && \
		ln -sf $(DYLIB_MAJOR_NAME) $(DYLIBNAME)
	$(INSTALL) $(STLIBNAME) $(INSTALL_LIBRARY_PATH)
