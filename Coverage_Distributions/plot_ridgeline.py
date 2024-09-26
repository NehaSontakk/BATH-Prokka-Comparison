import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import os
import glob

def read_coverage_data(file_path):
    """ Reads coverage data from a file, filtering for entries with sufficient length. """
    try:
        df = pd.read_csv(file_path)
        print(df.head())
        filtered_df = df[df['Length'] >= 500]  # Filtering for sequences with length >= 500
        return filtered_df['Coverage'].tolist()
    except Exception as e:
        print(f"Failed to read {file_path}: {e}")
        return []

def create_histogram(values, bins):
    """ Computes histogram for given values and bins. """
    hist, _ = np.histogram(values, bins=bins)
    return hist

def plot_histograms(data_files, colors, bins, output_file):
    """ Plots histograms for all provided data files on the same plot. """
    plt.figure(figsize=(12, 8))
    ax = plt.gca()

    binned_points = 0
    unbinned_points = 0

    for data_file, color in zip(data_files, colors):
        values = read_coverage_data(data_file)
        if values:  # Check if there are any values to plot
            if 'binned' in data_file:
                binned_points += len(values)
            else:
                unbinned_points += len(values)
            hist = create_histogram(values, bins)
            mid_points = 0.5 * (bins[:-1] + bins[1:])
            ax.plot(mid_points, hist, color=color)
            sns.kdeplot(values, ax=ax, color=color, fill=True, common_norm=False, alpha=0.3)

    plt.xlabel('Coverage')
    plt.ylabel('Frequency')
    plt.title('Metabat Coverage Distribution')
    plt.xticks(np.arange(0, 21, 1))  # Setting x-axis ticks at every unit
    plt.yticks(np.arange(0, max(hist) + 1, 250))  # Y-axis ticks at 250 increments
    plt.xlim(0, 20)  # Set x-axis limit to 20
    plt.legend(['Binned (Blue)', 'Unbinned (Red)'], title='Dataset Type', loc='upper right')
    plt.grid(True)

    print(f"Binned data points: {binned_points}")
    print(f"Unbinned data points: {unbinned_points}")

    if output_file:
        plt.savefig(output_file)
    plt.show()
    plt.close()

def main(base_directory):
    """ Process coverage data and plot histograms. """
    binned_files = glob.glob(os.path.join(base_directory, '**/*_binned_coverage.txt'), recursive=True)
    unbinned_files = glob.glob(os.path.join(base_directory, '**/*_unbinned_coverage.txt'), recursive=True)

    # Define bins for the histogram
    bins = np.linspace(1, 20, 95)  # Binning at 0.2 intervals from 1 to 20

    data_files = binned_files + unbinned_files
    colors = ['blue'] * len(binned_files) + ['red'] * len(unbinned_files)

    plot_histograms(data_files, colors, bins, 'combined_coverage_plot.pdf')

if __name__ == "__main__":
    base_directory = '/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/BINS_METASPADES_ASSEMBLY_11Sep24'
    main(base_directory)

