#!/bin/bash

#*----------Cluster specification----------
#SBATCH --job-name="03_map_reads"
#SBATCH --array=1-12
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=32
#SBATCH --time=20:00:00
#SBATCH --mem=128G
#SBATCH --output=/data/users/egraf/RNAseq/log_2/03_map_reads_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log_2/03_map_reads_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER='egraf'
WORKDIR="/data/users/${USER}/RNAseq"
OUTDIR="${WORKDIR}/3_hisat2_mapping_2"
OUTDIRBAM="${WORKDIR}/4_samtools_view_2"
OUTDIRSORTED="${WORKDIR}/5_samtools_sort_2"
FASTQCPATH="${WORKDIR}/1_1_fastp"
INDEXING="${WORKDIR}/2_hisat2_indexing_2"
METADATA="${WORKDIR}/metadata"
CONTAINERHISAT=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif
SAMPLELIST="${WORKDIR}/metadata/samplelist_fastqc2.tsv"



SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

echo "Strating process for ${SAMPLE}" >&2
#*----------Map reads of each sample to the reference genome with HISAT2---------

apptainer exec --bind ${OUTDIR} ${CONTAINERHISAT} hisat2 -x ${INDEXING}/homosapiens_hisat2_index -1 ${READ1} -2 ${READ2} -S ${OUTDIR}/${SAMPLE}.sam
echo "Mapping reads to reference genome completed for ${SAMPLE}" >&2

#*----------Convert sam files to bam files with Samtools---------
apptainer exec --bind ${OUTDIR} ${CONTAINERHISAT} samtools view -hbS ${OUTDIR}/${SAMPLE}.sam > ${OUTDIRBAM}/${SAMPLE}.bam
echo "Converting sam to bam completed for ${SAMPLE}" >&2

#*----------remove sam files---------
rm ${OUTDIR}/${SAMPLE}.sam
# echo "sam file removed for ${SAMPLE}" >&2

#*----------Sort bam files by genomic coordinates with Samtools---------
apptainer exec --bind ${OUTDIRBAM} ${CONTAINERHISAT} samtools sort -m 4G -@ 32 -o ${OUTDIRSORTED}/${SAMPLE}_sorted.bam -T temp ${OUTDIRBAM}/${SAMPLE}.bam 
echo "Sorting bam files completed for ${SAMPLE}" >&2

#*----------Index bam files using Samtools---------
apptainer exec --bind ${OUTDIRSORTED} ${CONTAINERHISAT} samtools index ${OUTDIRSORTED}/${SAMPLE}_sorted.bam
echo "Indexing bam files completed for ${SAMPLE}" >&2


