#!/bin/bash

#*----------Cluster specification----------
#SBATCH --job-name="04_count_reads"
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=8
#SBATCH --time=10:00:00
#SBATCH --mem=32g
#SBATCH --output=/data/users/egraf/RNAseq/log_2/04_count_reads_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log_2/04_count_reads_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
WORKDIR="/data/users/${USER}/RNAseq"
OUTDIR="${WORKDIR}/7_featurecounts"
PATHBAM="${WORKDIR}/5_samtools_sort_2"
METADATA="${WORKDIR}/metadata"
CONTAINERFCOUNT=/containers/apptainer/subread_2.0.1--hed695b0_0.sif


#*----------Count number of reads per gene with featureCounts---------

#-T 8: number of threads
#-p: input data contain paired-end reads
#-C: do not count chimeric fragments
#- s 0: unstranded read counting for all input files
#-Q 10: minimum mapping quality score
#-t exon: feature type
#-g gene_id: attribute typed used to group features into meta-features when GTF annotation provided
#-a: annotation file
#-G: reference genome
#-o: output file
apptainer exec --bind ${OUTDIR} ${CONTAINERFCOUNT} featureCounts -T 8 -p -C -s 0 -Q 10 -t exon -g gene_id -a ${METADATA}/Homo_sapiens.GRCh38.113.gtf -G ${METADATA}/Homo_sapiens.GRCh38.dna.primary_assembly.fa -o ${OUTDIR}/featureCounts_table.txt ${PATHBAM}/*.bam
echo "featureCount completed" >&2





