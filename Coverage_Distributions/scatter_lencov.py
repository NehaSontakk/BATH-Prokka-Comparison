import os
import pandas as pd
import matplotlib.pyplot as plt
import glob
import numpy as np

def read_and_aggregate_data(file_path):
    """ Reads coverage and length data from a CSV file, filtering for entries with sufficient length. """
    try:
        df = pd.read_csv(file_path)
        # Filter to include only data with length greater than 500 and within defined limits
        filtered_df = df
        return filtered_df
    except Exception as e:
        print(f"Failed to read {file_path}: {e}")
        return pd.DataFrame()

def aggregate_data_from_directory(base_directory, file_pattern):
    """ Aggregate data from all files matching the pattern in the directory tree. """
    aggregated_data = pd.DataFrame()
    for root, dirs, files in os.walk(base_directory):
        for file in files:
            if file_pattern in file and 'concoct_bins' in root:
                file_path = os.path.join(root, file)
                df = read_and_aggregate_data(file_path)
                if not df.empty:
                    aggregated_data = pd.concat([aggregated_data, df], ignore_index=True)
    return aggregated_data

def plot_data(binned_data, unbinned_data, output_filename):
    """ Plots a scatter plot of length versus coverage for the aggregated data. """
    plt.figure(figsize=(12, 8))
    if not binned_data.empty:
        plt.scatter('Coverage', 'Length', data=binned_data, color='blue', label='Binned', alpha=0.5, s=10)
    if not unbinned_data.empty:
        plt.scatter('Coverage', 'Length', data=unbinned_data, color='red', label='Unbinned', s=10)

    plt.xlabel('Coverage')
    plt.ylabel('Length')
    plt.title('Length vs Coverage Scatter Plot')
    plt.legend()
    plt.grid(True)

    # Setting x-ticks to every 1 unit on the x-axis
    plt.xticks(np.arange(0, 21, 1))  # This assumes your coverage goes up to 20, adjust if necessary

    plt.xlim(0, 20)  # Sets the x-axis limit from 0 to 20
    plt.ylim(0, 20000)  # Assuming you want to visualize up to a length of 20000

    plt.savefig(output_filename, format='png')
    plt.show()
    plt.close()

def main(base_directory):
    """ Main function to process directories and plot data. """
    binned_data = aggregate_data_from_directory(base_directory, '_binned_coverage.txt')
    unbinned_data = aggregate_data_from_directory(base_directory, '_unbinned_coverage.txt')

    plot_data(binned_data, unbinned_data, 'combined_length_vs_coverage_scatter.png')

if __name__ == "__main__":
    base_directory = '/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/BINS_METASPADES_ASSEMBLY_11Sep24'
    main(base_directory)

