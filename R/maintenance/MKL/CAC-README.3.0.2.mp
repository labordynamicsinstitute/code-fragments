### R-3.0.2 was configured with the uncommented lines below, SRL 10/3/12
### this is a high-performance build of R that links with Intel MKL
### source this file to reproduce the configuration (2a+2), or edit as desired
### during option-one builds, the Intel 12.1 compilers and libraries are assumed

# Additional Linux libraries:
## java-1.7.0-openjdk
## standard CentOS install +
#   sudo yum install readline-devel
#   sudo yum install libXt-devel
#   sudo yum install pango-devel cairo-devel
#
export MKLPATH=$MKLROOT/lib/intel64
export xP=MP
### choose how to link MKL 10.3.6, which is the MKL version that accompanies the Intel 12.1 compilers (uncomment one of the next four):

##(1a) MKL for Intel compilers, single-threaded, static
#export MKL="-Wl,--start-group $MKLPATH/libmkl_intel_lp64.a $MKLPATH/libmkl_sequential.a $MKLPATH/libmkl_core.a -Wl,--end-group -lpthread"

##(1b) MKL for Intel compilers, multithreaded, dynamic
#export MKL="-L${MKLPATH} -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread"

##(2a) MKL for GNU compilers, single-threaded, static
#export MKL="-Wl,--start-group $MKLPATH/libmkl_gf_lp64.a $MKLPATH/libmkl_sequential.a $MKLPATH/libmkl_core.a -Wl,--end-group -lpthread"

##(2b) MKL for GNU compilers, multithreaded, dynamic
export MKL="-L${MKLPATH} -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -liomp5 -lpthread"

### choose compiler suite (uncomment just one of the next two, it must match your choice above):

##(1) Intel 12.1 compilers 
#./configure --prefix=/cac/contrib/R-2.15.1 --with-blas="$MKL" --with-lapack="$MKL" CC=icc CFLAGS="-O3 -ip -mieee-fp" F77=ifort FFLAGS="-O3 -mieee-fp" CXX=icpc CXXFLAGS="-O3 -mieee-fp" FC=ifort FCFLAGS="-O3 -mieee-fp" LDFLAGS="-O3 $MKL"

##(2) GNU compilers
./configure --prefix=/cac/contrib/R-3.0.2-MKL/$xP --with-blas="$MKL" --with-lapack="$MKL" FFLAGS="-march=core2 -O3" CFLAGS="-march=core2 -O3 -m64" CXXFLAGS="-march=core2 -O3 -m64" FCFLAGS="-march=core2 -O3 -m64" LDFLAGS="-L${MKLPATH},-Bdirect,--hash-style=both,-Wl,-O1"

#===============================================================================
