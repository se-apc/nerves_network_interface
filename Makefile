# Variables to override
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# ERL_CFLAGS	additional compiler flags for files using Erlang header files
# ERL_EI_LIBDIR path to libei.a
# LDFLAGS	linker flags for linking all binaries
# ERL_LDFLAGS	additional linker flags for projects referencing Erlang libraries
# MIX		path to mix

EILOC:=$(shell find /usr/local/lib/erlang /usr/lib/erlang -name ei.h -printf '%h\n' 2> /dev/null | head -1)
ERL_CFLAGS ?= -I/usr/local/include -I$(EILOC) -I/usr/lib/erlang/usr/include/

ERL_EI_LIBDIR ?= /usr/lib/erlang/usr/lib
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR) -lei

LDFLAGS ?= -lmnl
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
CC ?= $(CROSSCOMPILER)gcc
MIX ?= mix

all: compile

compile:
	$(MIX) compile

test:
	$(MIX) test

%.o: %.c
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

priv/net_basic: src/erlcmd.o src/net_basic.o
	mkdir -p priv
	$(CC) $^ $(ERL_LDFLAGS) $(LDFLAGS) -o $@

# setuid root net_basic so that it can configure network interfaces (this is not run by default)
setuid: priv/net_basic
	sudo chown root:root $^
	sudo chmod +s $^

clean:
	$(MIX) clean
	rm -f priv/net_basic src/*.o

.PHONY: all compile test clean setuid
