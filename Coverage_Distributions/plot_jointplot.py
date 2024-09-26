import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import os

def read_and_aggregate_data(file_path):
    """Reads coverage and length data from a CSV file."""
    try:
        df = pd.read_csv(file_path)
        return df[df['Length'] > 500]  # Assuming a filter is still desired for 'Length' > 500
    except Exception as e:
        print(f"Failed to read {file_path}: {e}")
        return pd.DataFrame()

def aggregate_data_from_directory(base_directory, file_pattern):
    """Aggregates data from all files matching the pattern in the directory tree."""
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
    """Plots a jointplot with scatter and histograms for coverage and length."""
    # Combine the data and add a label for the source
    combined_data = pd.concat([
        binned_data.assign(Dataset='Binned'), 
        unbinned_data.assign(Dataset='Unbinned')
    ])

    # Set style for better visibility
    sns.set(style="whitegrid")

    # Create the jointplot specifically with histograms for the marginals
    g = sns.jointplot(x='Coverage', y='Length', data=combined_data, hue='Dataset',
                      kind='scatter', palette=['blue', 'red'], height=10,
                      joint_kws={'alpha': 0.6},
                      marginal_kws={'kde': False, 'bins': np.arange(0, 20.2, 0.2)},
                      marginal_ticks=True)  # Ensure marginal_ticks is True for better axis control
    
    # Setting limits and ticks
    g.ax_joint.set_xlim(0, 20)
    g.ax_joint.set_xticks(np.arange(0, 21, 1))
    g.ax_joint.set_ylim(500, 20000)  # Assuming you want to start from 500 for Length

    g.fig.suptitle('Scatter Plot with Marginal Histograms for Coverage and Length', fontsize=16)
    g.set_axis_labels('Coverage', 'Length')

    plt.subplots_adjust(top=0.9)  # Adjust for title
    plt.savefig(output_filename)
    plt.show()



def main(base_directory):
    """Main function to process directories and plot data."""
    binned_data = aggregate_data_from_directory(base_directory, '_binned_coverage.txt')
    unbinned_data = aggregate_data_from_directory(base_directory, '_unbinned_coverage.txt')
    plot_data(binned_data, unbinned_data, 'combined_length_vs_coverage_scatter.png')

if __name__ == "__main__":
    base_directory = '/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison/BINS_METASPADES_ASSEMBLY_11Sep24'
    main(base_directory)

