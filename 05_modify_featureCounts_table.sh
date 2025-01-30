#!/bin/bash

#maybe delete this part
#*----------Cluster specification----------
#SBATCH --job-name="05_modify_featureCounts_table"
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=8
#SBATCH --time=10:00:00
#SBATCH --mem=32g
#SBATCH --output=/data/users/egraf/RNAseq/log_2/05_modify_featureCounts_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log_2/05_modify_featureCounts_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
WORKDIR="/data/users/${USER}/RNAseq"
OUTDIR="${WORKDIR}/7_featurecounts"
FCTABLE=${OUTDIR}/featureCounts_table.txt
OUTFILE=${OUTDIR}/featureCounts_table_modified.txt


#*----------Remove first row of featureCounts_table & Remove columns Chr, Start, End, Strand and Length---------
tail -n +2 ${FCTABLE} | cut --complement -f2,3,4,5,6> ${OUTFILE}



