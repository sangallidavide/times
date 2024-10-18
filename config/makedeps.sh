#! /bin/sh 
# compute dependencies for the WanT directory tree

# run from directory where this script is
cd `echo $0 | sed 's/\(.*\)\/.*/\1/'` # extract pathname
# come back to AGWX HOME
cd ..  
#
TOPDIR=`pwd`
BINDIR=$TOPDIR/config

DIR_LIST="src/exatto src/collisions src/hamiltonian src/io src/floquet src/lumen"
SPECIAL_MODULES="\
  iso_fortran_env iso_c_binding mpi \
  devxlib fft_base fft_scalar fft_ggen fft_types \
  kinds constants \
  mp lexicalsort \
  mkl_dfti.f90 mkl_dfti_omp_offload omp_lib mklfft_gpu nvtx \
"

for DIR in $DIR_LIST
do
    # set inter-directory dependencies
    case $DIR in
        src  )   DEPENDS="../include"                ;;
    esac

    # generate dependencies file
    if test -d $TOPDIR/$DIR
    then
        cd $TOPDIR/$DIR
        $BINDIR/moduledep.sh  $DEPENDS > make.deps
        $BINDIR/includedep.sh $DEPENDS >> make.deps
    fi

    # handle special cases
    if test "$DIR" = "baselib"
    then
        mv make.deps make.deps.tmp
        sed 's/@fftw.c@/fftw.c/' make.deps.tmp > make.deps
    fi

    # eliminate dependencies on special modules
    for module in $SPECIAL_MODULES
    do
        mv make.deps make.deps.tmp
        grep -v "@$module@" make.deps.tmp > make.deps
    done

    test -e make.deps && rm make.deps.tmp

    # check for missing dependencies
    if grep @ make.deps
    then
        notfound=1
        echo WARNING: dependencies not found in directory $DIR
    else
        echo directory $DIR : ok
    fi
    #
    # eliminate missing deps to make the script working
    mv make.deps make.deps.tmp
    awk '{
           if ( match($0, "@") ) { 
               print "#", $0 
           } else {
               print 
           }
         }' make.deps.tmp > make.deps
    #
    test -e make.deps.tmp && rm make.deps.tmp
    #
done
#
if test "$notfound" = ""
then
    echo all dependencies updated successfully
fi
