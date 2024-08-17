#!/bin/bash
#SBATCH --job-name=bathsearch_parallel
#SBATCH --output=bathsearch_parallel_%j.out
#SBATCH --mem-per-cpu=4GB
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=32:00:00
#SBATCH --account=twheeler
#SBATCH --partition=standard

# Specify the bin file
bin_files=["bin.82","bin.16","bin.329","bin.121","bin.40", "bin.104"]

for bin_file in"${bin_files[@]}"; do
(

#Add the prokka running instructions
singularity exec /home/u13/nsontakke/prokka.sif prokka --outdir Prokka_output --prefix ${bin_file} /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/${bin_file}

echo "Process started at $(date)"

# Path to the DNA input file
input_file="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/${bin_file}.fa"

# TANTAN
tantan_exec="/xdisk/twheeler/nsontakke/Software/tantan-49/bin/tantan"
masked_dna_file="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/${bin_file}.masked.fa.fna"

# Run Tantan for masking DNA
${tantan_exec} -x N ${input_file} > ${masked_dna_file}

# BATH SEARCH
bathsearch_exec="/home/u13/nsontakke/BATH/src/bathsearch"
output_main_dir="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Output_Bathsearch_${bin_file}"
mkdir -p ${output_main_dir}

# Run Bacteria
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/${bin_file}_DNA_Bacteria_kingdom_sprot.fhmm --tblout ${output_main_dir}/${bin_file}_DNA_Bacteria_kingdom_sprot.tbl -o ${output_main_dir}/${bin_file}_DNA_Bacteria_kingdom_sprot.out ${masked_protein_dir}/Bacteria/sprot.masked ${masked_dna_file} &

# Run Archaea
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/${bin_file}_DNA_Archaea_kingdom_sprot.fhmm --tblout ${output_main_dir}/${bin_file}_DNA_Archaea_kingdom_sprot.tbl -o ${output_main_dir}/${bin_file}_DNA_Archaea_kingdom_sprot.out ${masked_protein_dir}/Archaea/sprot.masked ${masked_dna_file} &

# Run HAMAP
${bathsearch_exec} -o ${output_main_dir}/${bin_file}_HAMAP_bath.out --tblout ${output_main_dir}/${bin_file}_HAMAP_bath.tbl /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Input_Bathsearch/HAMAP_ALL.bhmm ${masked_dna_file} &

# Run on Bacteria/IS
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/${bin_file}_DNA_Bacteria_IS_sprot.fhmm --tblout ${output_main_dir}/${bin_file}_DNA_Bacteria_IS_sprot.tbl -o ${output_main_dir}/${bin_file}_DNA_Bacteria_IS_sprot.out ${masked_protein_dir}/Bacteria/IS.masked ${masked_dna_file} &

# Run on Bacteria/AMR
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/${bin_file}_DNA_Bacteria_AMR_sprot.fhmm --tblout ${output_main_dir}/${bin_file}_DNA_Bacteria_AMR_sprot.tbl -o ${output_main_dir}/${bin_file}_DNA_Bacteria_AMR_sprot.out ${masked_protein_dir}/Bacteria/AMR.masked ${masked_dna_file} &

# Run viral commands with codon tables 1 and 11
for ct in 1 11; do
    hmmout="${output_main_dir}/${bin_file}_DNA_Viruses_kingdom_sprot_ct${ct}.fhmm"
    tblout="${output_main_dir}/${bin_file}_DNA_Viruses_kingdom_sprot_ct${ct}.tbl"
    output="${output_main_dir}/${bin_file}_DNA_Viruses_kingdom_sprot_ct${ct}.out"
    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} ${masked_protein_dir}/Viruses/sprot.masked ${masked_dna_file} &
done

# Run bathsearch for each mitochondrial codon table
declare -a codon_tables=(2 3 4 5 9 13 14 16 21 22 23 24 25)
for ct in "${codon_tables[@]}"; do
    hmmout="${output_main_dir}/${bin_file}_DNA_Mitochondria_kingdom_sprot_ct${ct}.fhmm"
    tblout="${output_main_dir}/${bin_file}_DNA_Mitochondria_kingdom_sprot_ct${ct}.tbl"
    output="${output_main_dir}/${bin_file}_DNA_Mitochondria_kingdom_sprot_ct${ct}.out"
    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} ${masked_protein_dir}/Mitochondria/sprot.masked ${masked_dna_file} &
done
echo "Bathsearch completed at $(date)" &
wait
) &
done
wait
echo"All bin files processed."
