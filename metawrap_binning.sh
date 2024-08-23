#!/bin/bash
#SBATCH --job-name=metawrap_binning          # Job name
#SBATCH --output=metawrap_binning_%j.out     # Standard output and error log
#SBATCH --error=metawrap_binning_%j.err      # Error log
#SBATCH --ntasks=1                          # Number of tasks (usually 1 for a single command)
#SBATCH --cpus-per-task=16                  # Number of CPU cores per task
#SBATCH --mem=100G                          # Total memory (RAM) per node
#SBATCH --time=48:00:00                     # Time limit in the form D-HH:MM:SS
#SBATCH --account=twheeler                  # Account name
#SBATCH --partition=standard                # Partition name

# Initialize Conda and activate the environment
conda init bash
source ~/.bashrc
conda activate metawrap-env

#BINNING
metawrap binning -o /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING \
                  -t 16 \
                  -a /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/MEGAHIT_ASSEMBLY/final_assembly.fasta \
                  --metabat2 \
                  --maxbin2 \
                  --concoct \
                  /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INPUT_FILE_FORMAT/SRR10983013.fastq_1.fastq \
                  /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INPUT_FILE_FORMAT/SRR10983013.fastq_2.fastq


#BIN REFINEMENT
#Provide output locations for binning of the maxbin metabat2 and concot outputs
#SPECIFY CONTAMINATION (-x set to 50) AND COMPLETENESS (-c set to 50)
metawrap bin_refinement -o /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BIN_REFINEMENT -t 16 -A /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INITIAL_BINNING/metabat2_bins/ -B /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INITIAL_BINNING/maxbin2_bins/ -C /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INITIAL_BINNING/concoct_bins/ -c 50 -x 50

#Find how many bins were produces
cat /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BIN_REFINEMENT/metawrap_50_10_bins.stats | awk '$2>50 && $3<50' | wc -l

#Download bin stats from: BIN_REFINEMENT/figures/

#Vizualize the bin stats
metawrap blobology -a /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/MEGAHIT_ASSEMBLY/final_assembly.fasta -t 16 -o /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BIN_REFINEMENT/BLOBOLOGY --bins /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BIN_REFINEMENT/metawrap_50_10_bins  \
                  /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INPUT_FILE_FORMAT/SRR10983013.fastq_1.fastq \
                  /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/Assembly_MetaWrap/BINNING/INPUT_FILE_FORMAT/SRR10983013.fastq_2.fastq
