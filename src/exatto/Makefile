
include ../../make.inc

# import all config setup variables, among which $(includedir)
include $(REF_YDIR)/config/setup

# import from here variables $(libs) and $(precomp_flags)
include $(REF_YDIR)/config/mk/local/static_variables.mk
#libs= #-L$(compdir)/lib -lpol_function -ldipoles 
#-lbse -lacfdt -lqp -lpol_function -ldipoles -ltddft -lsetup -lqp_control -linterpolate -lcoulomb -lwf_and_fft -lstop_and_restart -linterface -lxc_functionals -ltiming -lcommon -loutput -lparser -lparallel -lbz_ops -lio_parallel -lio -lYio -llinear_algebra -lmatrices -lmodules -lcommunicate -lallocations -lmemory -ltools -lyambo_Ydriver_main -lyambo_Ydriver_interface -lyambo_Ydriver_options -ldriver   -lqe_pseudo -lmath77 -lslatec -llocal $(lslepc) $(lpetsc) $(lscalapack) $(lblacs) $(llapack) $(lblas) $(liotk) $(letsf) $(lnetcdff) $(lnetcdf) $(lhdf5) $(llibxc) $(lfft) $(lfutile) $(lyaml) -lm
#precomp_flags  = -D_RT -D_HDF5_LIB -D_HDF5_IO -D_PAR_IO -D_MPI -D_FFTW -D_SLEPC -D_SCALAPACK -D_OPENMP -D_TIMING -D_$(os)
dopts  = -D_RT $(precomp_flags)

exatto_libdir=../../lib
exatto_incdir=../../include

exatto_libs=-L$(exatto_libdir) -l_collisions -l_hamiltonian

srcdir=../../
folder="src/exatto"
IFLAG=-I

idriver=$(IFLAG)$(libdir)/yambo/Ydriver/include $(IFLAG)$(includedir)/driver $(IFLAG)$(includedir)/version
lf90include=$(IFLAG)./ $(IFLAG)$(exatto_incdir) $(IFLAG)$(includedir) $(IFLAG)$(includedir)/headers/common $(IFLAG)$(includedir)/headers/parser $(idriver)
lf90libinclude=$(iiotk) $(inetcdff) $(inetcdf) $(ipetsc) $(islepc) $(ihdf5) $(ilibxc) $(ifft) $(ifutile) $(iyaml) $(idriver)



#========================

.SUFFIXES :
.SUFFIXES : .o .c .f .f90 .F

# Yambo version
#
.F.o:
	@(eval $(fpp) $(dopts) $(lf90include) $(lf90libinclude) $(srcdir)$(folder)/$*.F > $*.tmp_source)
	@$(srcdir)config/replacer.sh $*.tmp_source
	@mv $*.tmp_source_space $*$(f90suffix)
	$(fc) -c $(fcflags) $(lf90include) $(lf90libinclude) $*$(f90suffix) > /dev/null 	
.f.o:
	@(eval $(f77) -c $(fflags) $(srcdir)$(folder)/$*.f)
.c.o:
	@(eval $(cc) $(cflags) $(dopts) $(linclude) -c $(srcdir)$(folder)/$*.c) > /dev/null


# QE version
#
#.f90.o:
#	$(FC) $(FCFLAGS) -c $<
#.c.o:
#	$(CC) $(CFLAGS)  -c $<

#========================

#
# At present mod_RT_control is compiled by yambo
#
#mod_RT_control.o
objs=\
mod_RT_lifetimes.o \
mod_RT_occupations.o \
mod_real_time.o \
mod_fields.o \
mod_RT_output.o \
mod_RT_control.o \
mod_RT_operations.o \
mod_plasma.o \
RT_free.o \
RT_carriers_object.o \
RT_driver.o


all: exatto
exatto: exatto.x


exatto.x: $(objs) exatto.o
	eval $(fc) $(fcflags) $(lf90include) $(lf90libinclude) -o $@ exatto.o $(objs) $(exatto_libs) $(libs)
	cd ../../bin ; ln -sf ../src/exatto/exatto.x ./

#exatto.x: $(objs)
#	$(fc) $(fcflags) $(objs) exatto.o -o $@ $(libs)
#	cd ../../bin ; ln -sf ../src/exatto/exatto.x ./
 
clean:
	-rm -rf *.f90 *.x *.o *.mod *.MOD *.a

#include ./make.deps
