import sys
import subprocess

# Install required packages
try:
    import re
    import pandas as pd
    import matplotlib.pyplot as plt
except ImportError:
    packages = ['pandas', 'matplotlib']
    for package in packages:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--quiet', package])
    import re
    import pandas as pd
    import matplotlib.pyplot as plt

from datetime import datetime
from collections import defaultdict
import os
import glob

def ensure_directory(path):
    """
    Create the specified directory if it does not exist.

    Args:
        path (str): The path to the directory.

    Returns:
        str: The path to the directory (created if it didn't exist).
    """
    os.makedirs(path, exist_ok=True)
    return path

def parse_log_and_analyze(log_files, output_csv_path):
    """
    Parse the provided log files and analyze the data.

    Args:
        log_files (list): A list of log file paths.
        output_csv_path (str): The path to save the CSV file.

    Returns:
        pandas.DataFrame: The DataFrame containing the analyzed data.
    """
    # Regex patterns to find specific log entries
    request_sent_pattern = re.compile(r'Request sent to http://sequencer.heurist.xyz/miner_request with data')
    nj_response_pattern = re.compile(r'Response from server for miner_id.*NJ')
    rate_limit_429_pattern = re.compile(r'received response: 429')
    request_completed_pattern = re.compile(r'Request ID.*completed.*')
    timestamp_pattern = re.compile(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}')  # Matches timestamps like 'YYYY-MM-DD HH:MM:SS,mmm'

    # Data structure to hold the count of different types of log entries
    log_summary = defaultdict(lambda: {'requests_sent': 0, 'NJ': 0, 'rate_limit_429': 0, 'requests_processed': 0})

    for file_path in log_files:
        with open(file_path, 'r') as file:
            for line in file:
                if not timestamp_pattern.match(line):
                    continue  # Skip non-timestamp lines

                try:
                    timestamp = datetime.strptime(line.split(' - ')[0], '%Y-%m-%d %H:%M:%S,%f')
                    hour_key = timestamp.strftime('%Y-%m-%d %H')
                except ValueError:
                    print(f"Skipping line due to format error: {line.strip()}")
                    continue

                if request_sent_pattern.search(line):
                    log_summary[hour_key]['requests_sent'] += 1
                if nj_response_pattern.search(line):
                    log_summary[hour_key]['NJ'] += 1
                if rate_limit_429_pattern.search(line):
                    log_summary[hour_key]['rate_limit_429'] += 1
                if request_completed_pattern.search(line):
                    log_summary[hour_key]['requests_processed'] += 1

    # Convert to DataFrame and save to CSV
    df = pd.DataFrame.from_dict(log_summary, orient='index').reset_index()
    df.columns = ['Date Hour', 'Requests Sent', 'NJ Responses', 'Rate Limit 429 Responses', 'Requests Processed']
    df.to_csv(output_csv_path, index=False)
    print("\nAdditional metrics for SD Miner processes\n")
    print()
    return df

def plot_data(df):
    """
    Plot the analyzed data from the DataFrame.

    Args:
        df (pandas.DataFrame): The DataFrame containing the analyzed data.
    """
    df['Date Hour'] = pd.to_datetime(df['Date Hour'], format='%Y-%m-%d %H')
    plt.figure(figsize=(14, 10))
    titles = ['Requests Sent', 'NJ Responses', 'Rate Limit 429 Responses', 'Requests Processed']
    colors = ['blue', 'green', 'red', 'purple']

    for i, column in enumerate(titles, start=1):
        plt.subplot(4, 1, i)
        plt.plot(df['Date Hour'], df[column], marker='o', linestyle='-', color=colors[i-1])
        plt.title(f"{column} Over Time")
        plt.ylabel('Count')

    plt.tight_layout()
    plt.show()

# Get the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Determine the base directory (parent of the script's directory if in utils, otherwise the same)
if os.path.basename(script_dir) == 'utils':
    base_dir = os.path.dirname(script_dir)
else:
    base_dir = script_dir

# Define the output directory as the 'logs' folder inside the base directory and ensure it exists
output_dir = os.path.join(base_dir, 'logs')
ensure_directory(output_dir)

# Adjust the glob pattern to match your log files in the miner-release directory
log_files = glob.glob(os.path.join(base_dir, 'miner-release', 'sd-miner*.log'))

# Define the output CSV file path
output_csv_path = os.path.join(output_dir, 'log_summary.csv')

# Execute analysis and plotting
if log_files:
    df = parse_log_and_analyze(log_files, output_csv_path)
    plot_data(df)
else:
    print("*SD Miner not active.")

# Install csvkit package
#subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--quiet', 'csvkit'])

# Display the CSV file using csvlook
os.system(f"csvlook {output_csv_path}")
