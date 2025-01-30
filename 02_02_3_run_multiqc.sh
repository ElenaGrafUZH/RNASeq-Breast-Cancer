#!/bin/bash

#*----------Cluster specification----------
#SBATCH --job-name="multiqc_2"
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=1g
#SBATCH --output=/data/users/egraf/RNAseq/log/multiqc2_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log/multiqc2_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
WORKDIR="/data/users/${USER}/RNAseq"
OUTDIR="${WORKDIR}/1_2_fastqc"
CONTAINERFASTQC=/containers/apptainer/fastqc-0.12.1.sif

#*----------cd to fastqc output folder----------
cd "${WORKDIR}/1_2_fastqc"

#*----------Load modules----------
module load MultiQC/1.11-foss-2021a

multiqc .
