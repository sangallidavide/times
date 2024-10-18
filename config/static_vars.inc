
libs=-L$(compdir)/lib -lpol_function -ldipoles -lbse -lacfdt -lqp -lpol_function -ldipoles -ltddft -lsetup -lqp_control -linterpolate -lcoulomb -lwf_and_fft -lstop_and_restart -linterface -lxc_functionals -ltiming -lcommon -loutput -lparser -lparallel -lbz_ops -lio_parallel -lio -lYio -llinear_algebra -lmatrices -lmodules -lcommunicate -lmodules -lallocations -lmemory -ltools

extlibs=-L$(compdir)/lib -lqe_pseudo -lmath77 -lslatec -llocal $(lslepc) $(lpetsc) $(lscalapack) $(lblacs) $(llapack) $(lblas) $(liotk) $(letsf) $(lnetcdff) $(lnetcdf) $(lhdf5) $(llibxc) $(lfft) $(lfutile) $(lyaml) -lm

#precomp_flags  = -D_RT -D_HDF5_LIB -D_HDF5_IO -D_PAR_IO -D_MPI -D_FFTW -D_SLEPC -D_SCALAPACK -D_OPENMP -D_TIMING -D_$(os)

IFLAG=-I

idriver=$(IFLAG)$(libdir)/yambo/Ydriver/include $(IFLAG)$(includedir)/driver $(IFLAG)$(includedir)/version

exatto_libdir=../../lib
exatto_incdir=../../include

linclude=$(idriver)
lf90include=$(IFLAG)./ $(IFLAG)$(exatto_incdir) $(IFLAG)$(includedir) $(IFLAG)$(includedir)/headers/common $(IFLAG)$(includedir)/headers/parser $(idriver)
lf90libinclude=$(iiotk) $(inetcdff) $(inetcdf) $(ipetsc) $(islepc) $(ihdf5) $(ilibxc) $(ifft) $(ifutile) $(iyaml) $(idriver)
