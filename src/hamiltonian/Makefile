include ../../config/make.inc

# import all config setup variables, among which $(includedir)
include $(REF_YDIR)/config/setup

# import from here variables $(libs) and $(precomp_flags)
include $(REF_YDIR)/config/mk/local/static_variables.mk

# redefines $(libs) and defines $(extlibs) $(exatto_libdir) $(lf90include) $(lf90libinclude)
include ../../config/static_vars.inc

dopts  = -D_RT -D_yambo $(precomp_flags)

include ../../config/rules.inc
include ./.objects

srcdir=../../
folder="src/hamiltonian"

target=lib_hamiltonian.a

all: $(target)

$(target): $(objs)
	eval $(ar) $(arflags) $(target) $(objs)
	echo $(target)   
	mv $(target) $(exatto_libdir) ; chmod u+x $(exatto_libdir)/$(target)
	if test -e hamiltonian.mod ; then  mv *.mod $(exatto_incdir); fi

clean:
	-rm -rf *.f90 *.x *.o *.mod *.MOD *.a

include ./make.deps
