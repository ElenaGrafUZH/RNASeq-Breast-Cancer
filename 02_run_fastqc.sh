#!/bin/bash

#*----------Cluster specification----------
#SBATCH --mail-type=fail
#SBATCH --job-name="02_fastqc"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=1000
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
OUTPUTFOLDER=/data/users/${USER}/RNAseq/1_fastqc
READSPATH=/data/courses/rnaseq_course/breastcancer_de/reads
CONTAINERFASTQC=/containers/apptainer/fastqc-0.12.1.sif

#*----------Load apptainer container for modules----------
#apptainer run ubuntu-figlet_v3.sif
#apptainer exec --bind bla.sif


# check quality of reads
# for k in `ls -1 reads/*.fastq.gz`; 
# do fastqc -t 2 ${k} > ${OUTPUTFOLDER};
# done
INPUTFILE=reads/HER21_R1.fastq.gz
apptainer exec --bind ${READSPATH} ${CONTAINERFASTQC} fastqc -t 2 -o ${OUTPUTFOLDER} ${INPUTFILE}
