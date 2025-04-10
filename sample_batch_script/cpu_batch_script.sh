#!/bin/bash
#SBATCH -N 1
#SBATCH -p RM 
#SBATCH -t 10:00:00
#SBATCH --ntasks-per-node=128

# type 'man sbatch' for more information and options
# this job will ask for 1 full RM node (128 cores) for 10 hours
# this job would potentially charge 1280 RM SUs

#echo commands to stdout
set -x

# move to working directory
# this job assumes:
# - all input data is stored in this directory
# - all output should be stored in this directory

#Loading modules
module load intel-oneapi
module load intel-mpi
# Set OpenMP threads with following command
export OMP_NUM_THREADS=1

#Submitting QE jobs with 128 MPI process with 1 OpenMP threads in 2 pools of k-point parallelization 
mpirun -np 128 /ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1-3/bin/pw.x -npool 2 -in pw.in > pw-np-128-npool-2.log
