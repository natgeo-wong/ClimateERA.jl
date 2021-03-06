#!/bin/bash

#SBATCH -p huce_intel # partition (queue)
#SBATCH -N 1 # number of nodes
#SBATCH -n 1 # number of cores
#SBATCH --mem-per-cpu=500 # memory pool for all cores
#SBATCH -t 1-00:00 # time (D-HH:MM)
#SBATCH -J "CliERA5_dwn"
#SBATCH --mail-user=useremail@serverhost.com
#SBATCH --mail-type=ALL
#SBATCH -o cliERA_dwn.%j.out # STDOUT
#SBATCH -e cliERA_dwn.%j.err # STDERR

## This is an example download script for submission to a cluster.  I use this script to
## submit jobs to the Harvard Odyssey/Cannon cluster.
## e.g. sbatch erad.sh era5-GLB-u_air-5hPa.py

module load Anaconda3/5.0.1-fasrc02

source activate base_env
python $1
