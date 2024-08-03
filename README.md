# BATH-Prokka-Comparison

## Data and initializations

1. Download query data from [Prokka db](https://github.com/tseemann/prokka/tree/master/db)
2. DNA input file: `/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/bin.82.fa.fna`
3. Query database: `/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Input_Bathsearch/kingdom` or `Prokka github db`

## Software Installed

- **Tantan**: `/xdisk/twheeler/nsontakke/Software/tantan-49/bin/tantan`
- **Bathsearch**: `/home/u13/nsontakke/BATH/src/bathsearch`

## Step 1: Protein Annotations using BATH and Prokka

#### Prokka Pipeline

Prokka is installed through singularity on the HPC for our environment. 

       singularity pull library://user/prokka:latest

Prokka can be run using: 

      singularity exec /home/u13/nsontakke/prokka.sif prokka --outdir Prokka_output --prefix my_genome genome.fasta


#### BATH Pipeline

The BATH pipeline is executed using a SLURM job script. Initially, the DNA input file is processed with Tantan for repeat masking to create a masked DNA file. Tantan is then used to mask protein sequences for various taxonomic groups (Bacteria, Archaea, Viruses, and Mitochondria) and specific functional categories (IS and AMR). This process is repeated for each group and category in the query database.

After Tantan masking, the Bath convert tool prepares the masked protein files for Bathsearch analysis. This conversion ensures the files are compatible with Bathsearch, facilitating accurate sequence search results. Bathsearch is subsequently employed to identify homologous sequences in the masked DNA and protein files. It runs in parallel for different groups (Bacteria, Archaea, HAMAP, IS, AMR, Viruses, and Mitochondria). For viruses, Bathsearch is executed with codon tables 1 and 11, while for mitochondria, it is run with multiple codon tables (2, 3, 4, 5, 9, 13, 14, 16, 21, 22, 23, 24, 25). Each task runs in the background, optimizing computational resource usage.

Bathsearch generates three output files for each query database:
- **tbl files**: Contain tabular results of the homology search, including query and target sequence identifiers, alignment positions, score metrics, and e-values.
- **.fhmm files**: Store hidden Markov model (HMM) search results, including HMM profile data, alignment scores, and matching sequence information.
- **.out files**: Provide descriptive information about sequences, alignments, and matches, including alignment visuals, scores, and e-values.

For detailed information on Bathsearch methodology, refer to the specified REFERENCE.

(Note: The step involving the combination of mitochondrial and tblout files using "combine_BATHhits_diffcodontables.py" is not included.)

## Step 2: Deduplicating BATH outputs

## Step 3: Aligning BATH and Prokka Annotations

## Step 4: 
