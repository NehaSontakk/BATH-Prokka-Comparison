#!/bin/bash
#SBATCH --job-name=metawrap_assembly         # Job name
#SBATCH --output=metawrap_assembly_%j.out    # Standard output and error log
#SBATCH --error=metawrap_assembly_%j.err     # Error log
#SBATCH --ntasks=1                           # Number of tasks (usually 1 for a single command)
#SBATCH --cpus-per-task=16                   # Number of CPU cores per task
#SBATCH --mem=100G                           # Total memory (RAM) per node
#SBATCH --time=48:00:00                      # Time limit in the form D-HH:MM:SS
#SBATCH --account=twheeler                   # Account name
#SBATCH --partition=standard                 # Partition name

conda init bash
source ~/.bashrc

conda activate metawrap-env

# Run MetaWRAP assembly with MetaSPAdes
metawrap assembly -1 /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/CLEAN_FASTQ/SRR10983013_1.fastq.2.unmerged.final.clean.fq \
                   -2 /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/CLEAN_FASTQ/SRR10983013_1.fastq.1.unmerged.final.clean.fq \
                   -m 100 -t 16 -o /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/MEGAHIT_ASSEMBLY

