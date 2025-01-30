#!/bin/bash

#*----------Cluster specification----------
#SBATCH --job-name="02_fastqc"
#SBATCH --array=1-12
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=2
#SBATCH --time=01:00:00
#SBATCH --mem=5g
#SBATCH --output=/data/users/egraf/RNAseq/log/array_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log/array_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
WORKDIR="/data/users/${USER}/RNAseq"
OUTDIR="${WORKDIR}/1_1_fastp"
SAMPLELIST="${WORKDIR}/metadata/samplelist.tsv"
READSPATH=/data/courses/rnaseq_course/breastcancer_de/reads
CONTAINERFASTP=/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif

SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`


#*----------Run fastp----------
mkdir -p ${OUTDIR}

apptainer exec --bind ${READSPATH} ${CONTAINERFASTP} fastp -i ${READ1} -I ${READ2} -o "${OUTDIR}/${SAMPLE}_1.fastq.gz" -O "${OUTDIR}/${SAMPLE}_2.fastq.gz" --detect_adapter_for_pe -h "${OUTDIR}/fastp_${SAMPLE}.html" -j "${OUTDIR}/fastp_${SAMPLE}.json" -R "fastp_${SAMPLE} Report"

#-i: read1 input file name
#-I: read2 input file name
#-o: read1 output file name
#-O: read2 output file name
#--detect_adapter_for_pe: enable adapter sequence auto-detection
#-h: html format report file name
#-j: json format report file name
#-R: report title


