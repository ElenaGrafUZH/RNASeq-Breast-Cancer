#!/bin/bash

#*----------Cluster specification----------
#SBATCH --mail-type=fail
#SBATCH --job-name="01_link_reads"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=1000
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'


#*----------Link to reads----------
ln -s /data/courses/rnaseq_course/breastcancer_de/reads .


