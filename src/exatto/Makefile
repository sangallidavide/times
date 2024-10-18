include ../../config/make.inc

# import all config setup variables, among which $(includedir)
include $(REF_YDIR)/config/setup

# import from here variables $(libs) and $(precomp_flags)
include $(REF_YDIR)/config/mk/local/static_variables.mk

# redefines $(libs) and defines $(extlibs) $(exatto_libdir) $(lf90include) $(lf90libinclude)
include ../../config/static_vars.inc

exatto_libs=-L$(exatto_libdir) -l_collisions -l_hamiltonian -l_io # -l_rtinterface
exatto_ldrv=-L$(exatto_libdir) -l_driver

dopts  = -D_RT -D_yambo $(precomp_flags)

include ../../config/rules.inc
include ./.objects

srcdir=../../
folder="src/exatto"

all: exatto.x

exatto.x: $(objs) exatto.o
	eval $(fc) $(fcflags) $(lf90include) $(lf90libinclude) -o $@ exatto.o $(objs) $(exatto_libs) $(libs) $(exatto_ldrv) $(extlibs)
	cd ../../bin ; ln -sf ../src/exatto/exatto.x ./exatto.x

clean:
	-rm -rf *.f90 *.x *.o *.mod *.MOD *.a

include ./make.deps
