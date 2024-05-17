import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import subprocess

# Function to process the log data and generate metrics
def process_log_file(log_file, output_csv, log_output):
    # Load the log data
    df = pd.read_csv(log_file, header=None, names=['Timestamp', 'GPU ID', 'Total Memory (MiB)', 'Used Memory (MiB)', 'Num PIDs', 'Num SD Miners', 'Num LLM Miners', 'Free Memory (MiB)', 'CPU Usage (%)'])
    
    # Convert timestamp to datetime
    df['Timestamp'] = pd.to_datetime(df['Timestamp'], format='%Y/%m/%d %H:%M:%S.%f')
    
    # Ensure all numeric columns are of correct type
    numeric_columns = ['Total Memory (MiB)', 'Used Memory (MiB)', 'Num PIDs', 'Num SD Miners', 'Num LLM Miners', 'Free Memory (MiB)', 'CPU Usage (%)']
    df[numeric_columns] = df[numeric_columns].apply(pd.to_numeric, errors='coerce')
    
    # Set the minute for grouping
    df['Minute'] = df['Timestamp'].dt.floor('min')
    
    # Aggregate data per minute
    minute_summary = df.groupby('Minute').agg({
        'GPU ID': 'count',  # Number of GPUs
        'Total Memory (MiB)': 'sum',
        'Used Memory (MiB)': 'sum',
        'Num PIDs': 'sum',
        'Num SD Miners': 'sum',
        'Num LLM Miners': 'sum',
        'Free Memory (MiB)': 'sum',
        'CPU Usage (%)': 'mean'
    }).reset_index()
    
    # Rename columns
    minute_summary.columns = ['Minute', 'Num GPUs', 'Total Mem', 'Used Mem', 'Num PIDs', 'Num SD', 'Num LLM', 'Free Mem', 'CPU Usage']
    
    # Set the hour for grouping
    minute_summary['Hour'] = minute_summary['Minute'].dt.floor('h')
    
    # Aggregate data per hour
    hourly_summary = minute_summary.groupby('Hour').agg({
        'Num GPUs': 'max',
        'Total Mem': 'max',
        'Used Mem': 'mean',
        'Num PIDs': 'max',
        'Num SD': 'max',
        'Num LLM': 'max',
        'Free Mem': 'mean',
        'CPU Usage': 'mean'
    }).reset_index()
    
    # Format the 'Hour' column to just date hour
    hourly_summary['Hour'] = hourly_summary['Hour'].dt.strftime('%Y-%m-%d %H')
    
    # Rename columns for better readability
    hourly_summary.columns = ['Date Hour', 'Num GPUs', 'Total Mem', 'Avg Used Mem', 'Num GPU PIDs', 'Num SD PIDS', 'Num LLM PIDS', 'Avg Free Mem', 'Avg CPU']
    
    # Save to CSV
    hourly_summary.to_csv(output_csv, index=False)
    
    # Write to log file
    with open(log_output, 'w') as f:
        f.write(hourly_summary.to_string(index=False))
    
    # Print that logs have been written
    print(f"Metrics written to {output_csv} and {log_output}")

    return hourly_summary

# Function to plot the GPU usage data
def plot_gpu_usage(df):
    fig, ax = plt.subplots(figsize=(12, 8))

    ax.plot(df['Date Hour'], df['Total Mem'], label='Total Mem')
    ax.plot(df['Date Hour'], df['Avg Used Mem'], label='Avg Used Mem')
    ax.plot(df['Date Hour'], df['Avg Free Mem'], label='Avg Free Mem')

    ax.set_xlabel('Date Hour')
    ax.set_ylabel('Memory (MiB)')
    ax.set_title('GPU Memory Usage')
    ax.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()

    plt.savefig('gpu_usage_metrics.png')
    plt.show()

# Function to display CSV using csvlook
def display_csv_with_csvlook(output_csv):
    try:
        result = subprocess.run(['csvlook', output_csv], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error using csvlook: {e}")

# Main function to process and visualize data
def main(log_file='gpu_usage.log', output_csv='hourly_metrics.csv', log_output='processed_log.txt'):
    df = process_log_file(log_file, output_csv, log_output)
    plot_gpu_usage(df)
    display_csv_with_csvlook(output_csv)

if __name__ == "__main__":
    main()
