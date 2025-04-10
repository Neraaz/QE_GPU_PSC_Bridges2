#!/bin/bash
#SBATCH --job-name=qe-job       # Job name
#SBATCH -N 1 # Number of nodes
#SBATCH -p GPU-shared
#SBATCH --gpus=v100-32:2
#SBATCH --ntasks-per-node=2 #ntask per node = 2 and taking 2 GPUs ensure 1 GPU per 1 MPI process
#SBATCH --cpus-per-task=5 # Number of CPU cores per task (adjust as per node config)
#SBATCH --mem=100G                # Total memory requested
#SBATCH -t 02:00:00             # Max time for the job
#SBATCH --output=qe_%j.out      # Standard output file

set -x

#Loading NVIDIA HPC SDK and providing necessary paths
module load nvhpc/22.9
export PATH=/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/compilers/bin:$PATH
export PATH=/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/cuda/bin:$PATH
export PATH="/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/comm_libs/openmpi4/openmpi-4.0.5/bin:$PATH"
export LD_LIBRARY_PATH="/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/comm_libs/openmpi4/openmpi-4.0.5/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/cuda/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/compilers/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/opt/packages/nvidia/hpc_sdk/Linux_x86_64/22.9/math_libs/lib64:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/ocean/projects/pscstaff/nnepal/winter_compet/fftw3_nvfortran/lib:$LD_LIBRARY_PATH"
# Set OpenMP threads with following command
export OMP_NUM_THREADS=10

#Setting OpenMPI communication process
export OMPI_MCA_pml=ob1
export OMPI_MCA_btl=tcp,self,vader

#Running QE job with 2 MPI processes in 2 pools of k-point parallelization
mpirun -np 2 /ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3/bin/pw.x -npools 2 -in pw.in > pw-np-2-npool-2-openmp-10.log
