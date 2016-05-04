first: all

#-----------

CFLAGS += -Wall -g -I. -I..
# CFLAGS += -DGMEM_CHECK=1

C_SOURCES = \
	../cookie.c \
	../date.c \
	../gmem.c \
	../uri.c \

OBJ_C_SOURCES = $(subst ../,./,$(patsubst %.c,%.o,$(C_SOURCES)))

%.o : ../%.c uri_tables.h
	cc $(CFLAGS) -c -o$@ $<

#-----------

show:
	echo $(OBJ_C_SOURCES)

all: libcookie.a

libcookie.a: $(OBJ_C_SOURCES)
	ar cr $@ $^

uri_tables.h: ../tools/encode/uri_tables.h
	cp $^ $@

gonzo: libcookie.a gonzo.o
	cc -Wall -g -o$@ gonzo.o -L. -lcookie

clean:
	rm -f libcookie.a
	rm -f $(OBJ_C_SOURCES)
	rm -f gonzo.o gonzo
	rm -fr gonzo.dSYM
	rm -f uri_tables.h
