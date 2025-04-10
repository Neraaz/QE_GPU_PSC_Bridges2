#!/bin/bash
#SBATCH -N 2
#SBATCH -p RM
#SBATCH -t 10:00:00
#SBATCH --ntasks-per-node=128

# type 'man sbatch' for more information and options
# this job will ask for 1 full RM node (128 cores) for 5 hours
# this job would potentially charge 640 RM SUs

#echo commands to stdout
set -x

# move to working directory
# this job assumes:
# - all input data is stored in this directory
# - all output should be stored in this directory
# - please note that groupname should be replaced by your groupname
# - PSC-username should be replaced by your PSC username
# - path-to-directory should be replaced by the path to your directory where the executable is
module load intel-oneapi
module load intel-mpi
#export PATH="/jet/home/nnepal/softwares/qe-7.3-par/bin:$PATH"
mpirun -np 256 /ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1/bin/pw.x -npool 2 -ndiag 4 -in pw.in > pw-np-256-npool-2-ndiag-4.log
