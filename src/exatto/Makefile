
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

exatto_libs=-L$(exatto_libdir) -l_collisions -l_hamiltonian -l_io

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
mod_RT_interpolate_tools.o \
WF_derivative.o \
RT_INTERPOLATION_driver_seed.o \
RT_alloc.o \
RT_apply.o \
RT_apply_field.o \
RT_apply_RWA.o \
RT_average_operator.o \
RT_build_T1_and_T2.o \
RT_carriers_number.o \
RT_carriers_object.o \
RT_carriers_temperature.o \
RT_current_AND_polarization.o \
RT_databases_IO.o \
RT_Dephasing_Matrix.o \
RT_Dephasing_step.o \
RT_do_it.o \
RT_driver.o \
RT_Dynamics_is_over.o \
RT_energy_components.o \
RT_entropy.o \
RT_EULER_step.o \
RT_EXP_step_accurate.o \
RT_EXP_step_std.o \
RT_Ext_fields.o \
RT_Field_Commensurable_Frequencies.o \
RT_field_from_file.o \
RT_Fluence_and_PI_kind.o \
RT_free.o \
RT_Glesser_evolve.o \
RT_G_lesser_init.o \
RT_Glesser_rotate.o \
RT_Hamiltonian_diagonalize.o \
RT_Hamiltonian.o \
RT_initialize.o \
RT_Integrator.o \
RT_Integrator_init.o \
RT_interpolation_doit_and_transfer.o \
RT_interpolation_driver.o \
RT_INV_step_accurate.o \
RT_INV_step_diago.o \
RT_INV_step_std.o \
RT_IO_type_time_steps.o \
RT_k_grid.o \
RT_Lifetimes_merge_driver.o \
RT_Lifetimes_merge_inter_k.o \
RT_Lifetimes_merge_intra_k.o \
RT_mean_lifetimes_and_temperatures.o \
RT_MEMORY_index.o \
RT_Observables.o \
RT_occupations_and_levels_init.o \
RT_occupations_eval.o \
RT_occupations_FIT.o \
RT_occupations_update.o \
RT_output_and_IO_driver.o \
RT_output.o \
RT_output_INIT.o \
RT_propagate_fields.o \
RT_Rabi_frequency_ALL_and_print.o \
RT_Rabi_frequency.o \
RT_RESTART_database_copy.o \
RT_Scattering_step.o \
RT_small_a.o \
RT_start_and_restart.o \
RT_time_step_update.o \
RT_update_TIME_CONF_descriptions.o 


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
