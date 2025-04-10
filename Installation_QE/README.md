Loading Modules for Intel oneAPI compilers
-------------------------------------------
First we load intel-oneapi and intel-mpi modules

module load intel-oneapi intel-mpi

module list ==> Check what modules are loaded. You will see other modules as well which are bundled with Intel-oneAPI module.

In this tutorial, we use LLVM (Low-Level Virtual Machine) based compilers which is not included in our user guide yet !

Fortran ==> ifx
C ==> icx
MPI wrapper ==> mpiifx (Fortran), mpiicx (C)

For OpenMP compilation

Old intel compiler use "-qopenmp" flag, but this one uses "-fopenmp" flag !


Installation 1
-------------------------------------------

./configure --prefix=/ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1 MPIF90=mpiifx F90=mpiifx CC=mpiicx --enable-parallel

Here, we are installing parallel QE with FFTW3, INTEL-MKL libraries, with intel compiler. Sequential threading is used for MKL libraries. Only MPI parallelization is supported. 


Installation 2
-------------------------------------------
./configure --prefix=/ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1-2 MPIF90=mpiifx F90=mpiifx CC=mpiicx --enable-parallel --with-scalapack=intel


I defined SCALAPACK_LIBS with dynamic linking. It won't use scalapack if ndiag is 1. If you don't use scalapack, it uses some custom distributed memory algorithm.  


Installation 3 adding OpenMP support
-------------------------------------------
Let's install fftw3 with intel-oneapi and intel-mpi with all support

Downloaded the source code:
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvzf fftw-3.3.10.tar.gz
cd fftw-3.3.10

Let's first install fftw3 only with openmp and serial version.

./configure CC=mpiicx CXX=mpiicx FC=mpiifx \
    --prefix=/ocean/projects/pscstaff/nnepal/fftw3 \
    --enable-shared \
    --enable-openmp \
    --enable-avx

./configure --prefix=/ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1-3 MPIF90=mpiifx F90=mpiifx CC=mpiicx --enable-parallel --enable-openmp --with-scalapack=intel

To compile with openmp, one need to provide -fopenmp flags every where during compilation. We also need to link mkl_intel_thread and iomp5 libraries instead of mkl_sequential.

Here, libiomp5 is runtime library for openmp support. 

OpenMP thread is invoked with export OMP_NUM_THREADS=n, n is number of threads.

Installation 4: Installation 3 with NVIDIA HPC SDK for CUDA support
-------------------------------------------
module load nvhpc/22.9

Here, we also need FFTW3 also for CPU apart from Cufft from CUDA.

Installing fftw3 with NVDIA HPC SDK
-------------------------------------------
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvzf fftw-3.3.10.tar.gz
cd fftw-3.3.10

configure fftw3
./configure CC=nvc CXX=nvc++ FC=nvfortran \
    --prefix=/ocean/projects/pscstaff/nnepal/winter_compet/new_QE/fftw3 \
    --enable-shared \
    --enable-openmp \
    --enable-avx

Installation

make -j$(nproc)
make install

setup FFT_LIBS flag as
FFT_LIBS="-L/ocean/projects/pscstaff/nnepal/winter_compet/fftw3_nvfortran/lib -lfftw3 -lfftw3_omp"

Type to check cuda version that can be set with "--with-cuda-runtime" flag. Although it is optional,
it is necessary to provide it if the system have multiple cuda installations.

nvcc --version 

We will find that the cuda runtime version is 11.7


provide path to all bin of nvhpc installation.
Also provide path to all library of nvhpc installation with LD_LIBRARY_PATH

Linking PATHS
export NVHPC_HOME="/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9"
export PATH="${NVHPC_HOME}/compilers/bin:$PATH"
export PATH="${NVHPC_HOME}/cuda/bin:$PATH"
export PATH="${NVHPC_HOME}/comm_libs/mpi/bin:$PATH"

Providing Libraries path
export LD_LIBRARY_PATH="${NVHPC_HOME}/cuda/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${NVHPC_HOME}/comm_libs/mpi/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${NVHPC_HOME}/compilers/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${NVHPC_HOME}/math_libs/lib64:$LD_LIBRARY_PATH"

Define BLAS and LAPACK LIBS
export BLAS_LIBS="-L$NVHPC_HOME/compilers/lib -lblas"
export LAPACK_LIBS="-L$NVHPC_HOME/compilers/lib -llapack -lblas"

Now we configure to create "make.inc" file

./configure --prefix=/ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1-4 --enable-openmp --enable-parallel --with-cuda=/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/cuda --with-cuda-cc=70 --with-scalapack=no --with-cuda-mpi=yes F90=mpif90 CC=mpicc MPIF90=mpif90 --with-cuda-runtime=11.7

Check make.inc and type following command to compile the code.

make pwall -j8

------------------------------------------------
Note: make.inc files for each installation process are located within this folder. Please check it and try to learn the differences within them. 

# Notes
-------------------------------------------------
You can link libraries in 2 different ways. 

static: /path_to_your_lib/library.a (look for .a file)
dynamic: -L/path_to_your_lib/ -llib1 -llib2 (look for .so file)

For INTEL MKL, these libraries can be found in

# $MKLROOT/lib/intel64/
# FFTW3 library can be found inside $MKLROOT/interfaces/fftw3xf

For NVIDIA HPC SDK

# Look for different libraries within $NVHPC_ROOT folder
# FFTW3 library needs to be installed with NVIDIA SDK.


If your codes uses different dependencies with "#include" statement , you need to provide include folder of those dependencies with include flag.

#Look for lines with "-I/path_to_include_folder_of_dependencies" in make.inc file.

******************** QE for H100 GPUs **************************************************

With --with-cuda-cc=90 and using NVIDIA HPC SDK 23.7, where cuda version is 12.2 the code compiles nicely and ran the calculation.

New NVHPC_HOME=/opt/packages/nvhpc/v23.7/Linux_x86_64/23.7
Linking paths and Libraries:

export PATH="${NVHPC_HOME}/compilers/bin:$PATH"
export PATH="${NVHPC_HOME}/cuda/bin:$PATH"
export PATH="${NVHPC_HOME}/comm_libs/mpi/bin:$PATH"

Providing Libraries path
export LD_LIBRARY_PATH="${NVHPC_HOME}/cuda/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${NVHPC_HOME}/comm_libs/mpi/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${NVHPC_HOME}/compilers/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${NVHPC_HOME}/math_libs/lib64:$LD_LIBRARY_PATH"

Configuration was:
./configure --prefix=/ocean/projects/pscstaff/nnepal/qe-7.3-3 --enable-openmp --enable-parallel --with-cuda=/opt/packages/nvhpc/v23.7/Linux_x86_64/23.7/cuda --with-cuda-cc=90 --with-scalapack=no --with-cuda-mpi=yes FC=mpif90 F90=nvfortran CC=mpicc cc=mpicc CXX=mpicxx cxx=mpicxx MPIF90=mpif90 mpif90=mpif90 --with-cuda-runtime=12.2


For accurate timing, it is recommended to use the `-DUSE_NVTX` flag is included in the list of `DFLAGS`. It didn't work just adding the flag. May be package need to be installed.

I included LD_FLAGS = -L/path_to_cuda_lib -lnvToolsExt. It installed without any errors.

I am also checking if this installation also works for V100 GPUs. After that, I will focus on CPUs too. Just to ensure that the installation works for all systems available.

Next, I will link Eigensolver_gpu and its libraries. I am using NVIDIA HPC SDK 23.7. I changed flags and compilers in Make file within EIGEN_GPU folder. Simply, type make all to compiler library and test the driver for sm90 architecture (H100). Instead of intel compilers we simply link lapack and blas libraries of SDK. We can simply use serial compilers "nvc" and "nvfortran" to compile C and Fortran codes. Also provide path to bin and lib directories corresponding to NVHPC 23.7 version. 

Linking Eigensolver_gpu library is simple. Simple add path to "lib_eigsolve.a" as LD_LIBS+= ..... Make sure, you use the same NVIDIA HPC SDK and cuda version. It compiled without error. Now its time to check if the performance has been enhanced. 

How about installing specifically for Intel AVX2 instruction with flags. FFLAGS, CFLAGS, CXXFLAGS as "-O3 -march=core-avx2" with slightly aggressive optimization.
