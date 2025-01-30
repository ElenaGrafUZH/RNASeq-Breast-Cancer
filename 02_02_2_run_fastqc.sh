#!/bin/bash

#*----------Cluster specification----------
#SBATCH --job-name="02_04_fastqc"
#SBATCH --array=1-12
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=1g
#SBATCH --output=/data/users/egraf/RNAseq/log/array_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log/array_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
WORKDIR="/data/users/${USER}/RNAseq"
OUTDIR="${WORKDIR}/1_2_fastqc"
SAMPLELIST="${WORKDIR}/metadata/samplelist_fastqc2.tsv"
READSPATH=/data/users/egraf/RNAseq/1_1_fastp
CONTAINERFASTQC=/containers/apptainer/fastqc-0.12.1.sif

SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`


#*----------Run fastqc----------
mkdir -p ${OUTDIR}

apptainer exec --bind ${READSPATH} ${CONTAINERFASTQC} fastqc -t 1 -o ${OUTDIR} ${READ1}
apptainer exec --bind ${READSPATH} ${CONTAINERFASTQC} fastqc -t 1 -o ${OUTDIR} ${READ2}



