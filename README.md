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

Prokka (Prokaryotic Genome Annotation Pipeline) is a well known widely used tool designed for rapid annotation of prokaryotic genomes. Prokka identifies and annotates genomic elements such as coding sequences (CDS), transfer RNAs (tRNAs), ribosomal RNAs (rRNAs), and other non-coding features in bacterial, archaeal, and viral genomes. Prokka expects input as preassembled genomic DNA sequences in FASTA format, typically scaffold sequences from de novo assembly software. The tool leverages several external feature prediction tools, including Prodigal for CDS, RNAmmer for rRNA, Aragorn for tRNA, SignalP for signal peptides, and Infernal for non-coding RNA. Although we focus on CDS for our analysis. It uses a hierarchical method for protein annotation, starting with trustworthy user-provided datasets, followed by UniProt bacterial proteins, RefSeq proteins for specific genera, and hidden Markov model profiles from Pfam and TIGRFAMs. Prokka outputs a comprehensive set of files, including FASTA files for original contigs and translated genes, feature tables, GenBank files, GFF files, and summary statistics. 

Prokka is installed through singularity on the HPC for our environment. 

       singularity pull library://user/prokka:latest

Prokka can be run using: 

      singularity exec /home/u13/nsontakke/prokka.sif prokka --outdir Prokka_output --prefix bin152 /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/bin.158.fa


#### BATH Pipeline

The BATH pipeline is executed using a SLURM job script. Initially, the DNA input file is processed with Tantan for repeat masking to create a masked DNA file. Tantan is then used to mask protein sequences for various taxonomic groups (Bacteria, Archaea, Viruses, and Mitochondria) and specific functional categories (IS and AMR). This process is repeated for each group and category in the query database.

After Tantan masking, the Bath convert tool prepares the masked protein files for Bathsearch analysis. This conversion ensures the files are compatible with Bathsearch, facilitating accurate sequence search results. Bathsearch is subsequently employed to identify homologous sequences in the masked DNA and protein files. It runs in parallel for different groups (Bacteria, Archaea, HAMAP, IS, AMR, Viruses, and Mitochondria). For viruses, Bathsearch is executed with codon tables 1 and 11, while for mitochondria, it is run with multiple codon tables (2, 3, 4, 5, 9, 13, 14, 16, 21, 22, 23, 24, 25). Each task runs in the background, optimizing computational resource usage.

Bathsearch generates three output files for each query database:
- **tbl files**: Contain tabular results of the homology search, including query and target sequence identifiers, alignment positions, score metrics, and e-values.
- **.fhmm files**: Store hidden Markov model (HMM) search results, including HMM profile data, alignment scores, and matching sequence information.
- **.out files**: Provide descriptive information about sequences, alignments, and matches, including alignment visuals, scores, and e-values.

For detailed information on Bathsearch methodology, refer to the specified REFERENCE.

       sbatch tantan_bathsearch.sh 

(Note: The step involving the combination of mitochondrial and tblout files using "combine_BATHhits_diffcodontables.py" is not included.)

## Step 2: Deduplicating BATH outputs

A method for filtering and deduplicating genomic data is designed to enhance the accuracy and reliability of sequence alignments by leveraging E-value thresholds and alignment overlap metrics. Initially, an E-value threshold of 0.000001 is applied to exclude low-confidence alignments. Subsequently, the DNA strand (positive or negative) is identified based on alignment positions. For each strand, a series of deduplication steps are performed:

100% Deduplication: Exact duplicates are identified and removed by comparing E-values and scores, retaining only the highest quality alignments.
70% Deduplication: Alignments with significant overlap (≥70%) are addressed by comparing E-values and sequence lengths, with the more reliable alignment being retained.
<70% Deduplication: For alignments with minor overlap (0.01% to <70%), adjustments are made to the alignment positions to resolve conflicts, ensuring non-redundancy of the retained alignments.

Each deduplication step is applied to ensure that the final dataset is both comprehensive and non-redundant, providing high-confidence data for subsequent analyses. This method is applied separately to positive and negative strands, allowing for tailored processing and accurate strand-specific results.

      Specify input directory: path to all the .tbl outputs for the 
Run [BATH_file_deduplication_(Positive_Negative).ipynb](https://github.com/NehaSontakk/BATH-Prokka-Comparison/blob/main/BATH_file_deduplication_(Positive_Negative).ipynb)

## Step 3: Aligning BATH and Prokka Annotations

Script performs a comprehensive comparison between genomic annotations produced by Prokka and BATH. 

For both BATH and Prokka outputs. The code generates BED files for different genomic regions, segregates them based on DNA strands, and runs operations to find overlaps and unique annotations between the two datasets using the bedops suite of tools.It combines the resulting files by prefix, ensuring that all directories are created if they don't exist. Finally, the code analyzes the overlapping and unique regions, categorizes them, and visualizes the data with a Venn diagram to provide insights into overlap classification catrgory of each annotation.

      Specify input directory: path to all prokka_annotation.gff file and bath_deduplicated.xlsx file 
Run [Updated_Contig_comparison_identifying_gaps_Prokka_vs_BATH.ipynb](https://github.com/NehaSontakk/BATH-Prokka-Comparison/blob/main/Updated_Contig_comparison_identifying_gaps_Prokka_vs_BATH.ipynb)

## Step 4: Comparison of Annotation Coverage by BATH and Prokka per Contig

This script is used to evaluate and compare genomic annotations between Prokka and BATH. The BATH data was separated into positive and negative strands, with start and end positions adjusted accordingly. Prokka annotations were filtered to separate hypothetical proteins from annotated ones. To assess the coverage of annotations on contigs, length of sequence covered by annotations for each contig is calculated. These lengths were used to compute the percentage of each contig covered by Prokka annotations, BATH annotations, and hypothetical proteins (Prokka unannotated regions). The coverage of contigs is visualised using bar plots, depicting the percentage of coverage by different annotation sources and the proportion of unannotated regions. Additionally, we calculated and plotted the number of annotations per contig for both Prokka and BATH.

      Specify input files: path to all prokka_annotations_save, bath_dedup_annotations_save, bath_prokka_alignment
Run [Contig_coverage_comparison.ipynb](https://github.com/NehaSontakk/BATH-Prokka-Comparison/blob/main/Contig_coverage_comparison.ipynb)

## Step 5: Frameshifts

## Step 6: Comparison of alignment length Prokka vs BATH

The script compares the lengths of annotations predicted by BATH, Prokka, and Prodigal, focusing on how these lengths align and differ across different categories of overlaps between the annotations of the two tools. Prokka .faa files, generated as output by the tool, are used to gather the protein sequences for final Prokka annotations. HMMs for HAMAP-specific annotations by Prokka are gathered separately. The script iterates through these, performing sequence alignment between Prodigal ORF amino sequences (also gathered as Prokka output) and Prokka Uniprot protein sequences using phmmer. E-values and alignment lengths are extracted and added to the DataFrame. The script visualizes the comparison between Prodigal ORF lengths and Prokka annotation lengths using scatter plots, highlighting differences and frameshift counts. To ensure comparability with BATH annotations, Prokka amino acid lengths are adjusted by multiplying to match DNA alignment lengths. Scatter plots are then created to compare these adjusted Prokka lengths with BATH lengths and to visualize the distribution of frameshifts.

      The script starts by loading Prokka and BATH annotated data from Excel files into pandas DataFrames. 
Run [Length_comparison_of_annotations_generated_by_BATH_and_Prokka.ipynb](https://github.com/NehaSontakk/BATH-Prokka-Comparison/blob/main/Length_comparison_of_annotations_generated_by_BATH_and_Prokka.ipynb)

## Step 7: Comparison of annotation labels for BATH and Prokka alginments 

This script gathers data where annotations from both BATH and Prokka align. It then compares annotation labels between these two sources at both the text level (direct string comparison) and the functional level (by querying eggNOG database identifiers for corresponding COG (Clusters of Orthologous Groups) annotations using a RESTful API from UniProt).
A comparison of the COG annotations is conducted by applying custom functions that fetch eggNOG IDs for proteins annotated by both BATH and Prokka, to assess the consistency and accuracy of annotations across the two databases. These comparisons are then recorded and visually represented using a treemap to depict the proportion of matching, mismatching, and missing annotations, providing a clear and informative visualization of the data alignment quality.

The script starts by loading Prokka and BATH annotated data from Excel files into pandas DataFrames. 
Run [Annotation_Name_Comparison.ipynb](https://github.com/NehaSontakk/BATH-Prokka-Comparison/blob/main/Annotation_Name_Comparison.ipynb)
