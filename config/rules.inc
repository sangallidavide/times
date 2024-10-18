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

