# You have 3 different folders
#Installation_QE: Follow this folder to install QE with different configurations.
make.inc_1 ==> Reference make.inc file for MPI installation without SCALAPACK
make.inc_2  ==> MPI with SCALAPACK
make.inc_3  ==> MPI + SCALAPACK + OpenMP
make.inc_4  ==> MPI + OpenMP + CUDA support
README.md   ==> Follow this file for installation

#sample_batch_script: Sample batch script to submit calculations on Bridges2 system
cpu_batch_script.sh ==> Sample batch script for RM partition
gpu_batch_script.sh ==> Sample batch script for GPU-shared partition

#tests: Perform QE calculations
benchmarks: Folders with benchmarks to be tested.
README.md : Follow this file for calculations
reference_calculations: Just check what output files are supposed to be.
