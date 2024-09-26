import os
import re
import pandas as pd

def extract_coverage_from_fasta(directory, filename, output_filename):
    """
    Extracts coverage and length values from fasta file headers, filters by length,
    and saves them to a CSV.
    """
    # Regex to capture coverage and length values
    header_pattern = re.compile(r'length_(\d+)_cov_([\d\.]+)')
    filepath = os.path.join(directory, filename)
    data = []

    with open(filepath, 'r') as file:
        for line in file:
            if line.startswith('>'):
                match = header_pattern.search(line)
                if match:
                    length = int(match.group(1))
                    coverage = float(match.group(2))
                    if length > 500:  # Filter to include only IDs with length greater than 500
                        data.append({'Length': length, 'Coverage': coverage})

    # Create DataFrame and save to CSV
    if data:
        df = pd.DataFrame(data)
        df.to_csv(os.path.join(directory, output_filename), index=False)
    else:
        print(f"No suitable data found in {filename} to save.")

def process_directory(base_directory):
    """
    Processes each directory for .fa files, extracts and saves coverage data based on length.
    """
    for root, dirs, files in os.walk(base_directory):
        if 'concoct_bins' in root:
            srr_name = os.path.basename(os.path.dirname(root))
            binned_files = [f for f in files if f.endswith('.fa') and 'unbinned' not in f]
            unbinned_file = next((f for f in files if f == 'unbinned.fa'), None)

            # Process binned files
            for file in binned_files:
                extract_coverage_from_fasta(root, file, f"{srr_name}_binned_coverage.txt")

            # Process unbinned file
            if unbinned_file:
                extract_coverage_from_fasta(root, unbinned_file, f"{srr_name}_unbinned_coverage.txt")

if __name__ == "__main__":
    base_directory = '/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/BINS_METASPADES_ASSEMBLY_11Sep24'
    process_directory(base_directory)

