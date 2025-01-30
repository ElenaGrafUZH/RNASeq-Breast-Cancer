#!/bin/bash

#*----------Cluster specification----------
#SBATCH --job-name="03_hisat2_indexing"
#SBATCH --mail-type=fail
#SBATCH --cpus-per-task=16
#SBATCH --time=03:00:00
#SBATCH --mem=64g
#SBATCH --output=/data/users/egraf/RNAseq/log_2/03_hisat_indexing_%J.out
#SBATCH --error=/data/users/egraf/RNAseq/log_2/03_hisat_indexing_%J.err
#SBATCH --partition=pibu_el8

#*----------Variables----------
USER=egraf
WORKDIR=/data/users/${USER}/RNAseq
OUTDIR=${WORKDIR}/2_hisat2_indexing_2
FASTQCPATH=${WORKDIR}/1_1_fastp
METADATA=${WORKDIR}/metadata
CONTAINERHISAT=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif

#*----------Get reference files---------
cd ${METADATA}
wget ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz
wget -O checksum_fasta ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/CHECKSUMS
wget -O checksum_gtf ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/CHECKSUMS

#*----------Check Files---------
cd ..
checksumGenom= sum ${METADATA}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
checksumAnnotation= sum ${METADATA}/Homo_sapiens.GRCh38.113.gtf.gz

controlChecksum1= grep "Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz" ${METADATA}/checksum_fasta | awk '{print$1, $2}'
controlChecksum2= grep "Homo_sapiens.GRCh38.113.gtf.gz" ${METADATA}/checksum_gtf | awk '{print$1, $2}'

if ["$checksumGenom" = "$controlChecksum1"] && ["$checksumAnnotation" = "$controlChecksum2"]; then
    echo "Dowloaded files intact" >&2


    #*-------Unzip files------
    gunzip ${METADATA}/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz 
    gunzip ${METADATA}/Homo_sapiens.GRCh38.113.gtf.gz

    #*----------Create Index Files for HISAT2---------
    echo "Starting Indexing" >&2
    apptainer exec --bind ${METADATA} ${CONTAINERHISAT} hisat2-build ${METADATA}/Homo_sapiens.GRCh38.dna.primary_assembly.fa ${OUTDIR}/homosapiens_hisat2_index
    echo "Indexing Done" >&2

else
    echo "Downloaded files NOT intact" >&2

fi