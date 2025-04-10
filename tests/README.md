#Go to benchmark directory. You have 2 different folder based on 2 different calculations.

1. Gold surface with 112 atoms. --> This calculation fix crystal structure and only perform electronic SCF calculations.
2. Germanium defect in Silicon  --> This calculations also change crystal structure in addition to electronic SCF.

For calculations, you need following different files:

#QE input file: pw.in

This file has structure of crystal system, simulation conditions such as plane-wave cutoff and k-point mesh

#Pseudopotential (PP) files (.UPF extension) of each atoms in the system.

For Gold, you need PP of gold only.

For second problem, You need PP of both Silicon and Germanium

#You need batch script to submit calculations in the cluster.

 Copy batch script from sample_batch_script folder for CPUs and GPUs calculations.


## Make copy of these folder based on different installations
  1. MPI without scalapack (foldername-cpu-1)
  2. MPI with scalapack (foldername-cpu-2)
  3. MPI+OpenMP with scalapack (foldername-cpu-3)
  4. GPU+MPI+OPenMP (foldername-gpu)

#Now one can submit job with following commands

sbatch job_script

# To use executables from different installation one can change follwing line in the job scripts.

  #!/bin/bash
  #SBATCH -N 1      #This determines number of nodes requested
  #SBATCH -p RM     #Partition name
  #SBATCH -t 10:00:00  #Walltime requested
  #SBATCH --ntasks-per-node=128 #Number of cores per each node
  
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
  export OMP_NUM_THREADS=1    #Change this number for different OpenMP threads
  
  #Submitting QE jobs with 128 MPI process with 1 OpenMP threads in 2 pools of k-point parallelization 
  mpirun -np 128 /ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1-3/bin/pw.x -npool 2 -in pw.in > pw-np-128-npool-2.log


#mpirun
It instruct to use MPI process for the calculation

# -np 128
The calculations will be divided into 128 MPI processes

# /ocean/projects/pscstaff/nnepal/winter_compet/qe-7.3.1-3/bin/pw.x
Path to my QE executable "pw.x". Change this to your executable

# -npool  ==> Number of pools for k-point parallelization


You can also add "-ndiag <n>" to explore linear-algebra parallelization. Here, n is number such that its square root is an integer value. If you use 16, then matrices are divided into smaller 4 x 4 matrices to perform calculations, especially in diagonilation.

# -in pw.in ==> 
It determine the input is "pw.in".

# > pw-np-128-npool-2.log

Our standard output will be written in this file. Rename this so that each output file will be different from others. For example, if you want to use 32 MPI process and 4 OpenMP threads to use your 128 cores, output can be renamed as pw-np-32-npool-2-openmp-4.log.

Your last few lines of output files will be as follows:
--------------------------------------------------------
Parallel routines

     PWSCF        :  22m26.01s CPU  24m15.98s WALL


   This run was terminated on:  14:54:55  26Feb2025

=------------------------------------------------------------------------------=
   JOB DONE.
=------------------------------------------------------------------------------=
---------------------------------------------------------

You will record WALL time of 24m15.98s ==> convert into seconds as your performance metrics. 


Experiment with different parallelization to obtain parallelization that provides optimal performance for both CPUs and GPUs.

1. MPI + OPenMP process
2. K-point parallelization (-npool)
3. Linear-algebra parallelization (-ndiag)

-----------------------------------------------------------------------------
Reference calculations for ausurf112 is presented. 

Only thing, you can check with reference calculations is the total energy. 
Run following commands, you will get that the total energy within different calculations is almost same and vary only after 5 decimal place.

grep ! `find . -name *.log` | awk '{print $1 $5}'

# For assignments 3, you can create different plots

1. First, plot the walltime as a function of the number of MPI processes while keeping other parallelization parameters fixed.  

2. For calculations using fewer than 64 cores, select the RM partition, whereas for calculations using up to 128 cores, continue using the RM partition.  

3. Once the optimal number of MPI processes is determined, explore the parameters npool and ndiag separately by varying only one at a time.  

4. Next, plot the walltime as a function of npool and then plot the walltime as a function of ndiag to analyze their effects on performance.  

5. After identifying the optimal values for npool and ndiag, investigate different combinations of MPI and OpenMP while keeping these optimal values fixed.  

6. Finally, apply a similar methodology for GPU-based calculations, adjusting the parallelization strategies accordingly to achieve optimal performance.  

Note: There is no right or wrong answer, but the score will be given based on performance and the completion of the assigned tasks.
