import pandas as pd
import re
import glob
import os
import subprocess
from termcolor import colored

def parse_log_file(file_path):
    """
    Parses a log file and extracts structured data.
    
    Args:
        file_path (str): Path to the log file.
        
    Returns:
        pd.DataFrame: DataFrame containing parsed log data.
    """
    log_entries = []
    with open(file_path, 'r') as file:
        for line in file:
            if re.match(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}', line):
                parsed_entry = parse_log_entry(line)
                if parsed_entry:
                    log_entries.append(parsed_entry)
    return pd.DataFrame(log_entries)

def parse_log_entry(log_entry):
    """
    Parses a single log entry.
    
    Args:
        log_entry (str): A log entry string.
        
    Returns:
        dict: Parsed log entry.
    """
    pattern = r'^(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) - (?P<logger>\w+) - (?P<level>\w+) - (?P<message>.+)$'
    match = re.match(pattern, log_entry)
    if match:
        entry = match.groupdict()
        model_match = re.search(r'Model ID: (\S+)', log_entry)
        miner_match = re.search(r'Miner ID: (\S+)', log_entry)
        if model_match:
            entry['model_id'] = model_match.group(1)
        else:
            entry['model_id'] = 'Unknown'
        if miner_match:
            entry['miner_id'] = miner_match.group(1)
        else:
            entry['miner_id'] = 'Unknown'
        return entry
    return None

def extract_metrics(df):
    """
    Extracts relevant metrics from the log DataFrame.
    
    Args:
        df (pd.DataFrame): DataFrame containing log data.
        
    Returns:
        pd.DataFrame: DataFrame with extracted metrics.
    """
    df['timestamp'] = pd.to_datetime(df['timestamp'], format='%Y-%m-%d %H:%M:%S,%f')
    df['tokens'] = df['message'].str.extract(r'Completed processing (\d+) tokens').astype(float)
    df['time'] = df['message'].str.extract(r'Time: ([\d.]+)').astype(float)
    df['http_errors'] = df['message'].str.contains('HTTPConnectionPool', na=False)
    df['cuda_errors'] = df['message'].str.contains('CUDA out of memory', na=False)
    return df

def aggregate_metrics(df):
    """
    Aggregates metrics on an hourly basis.
    
    Args:
        df (pd.DataFrame): DataFrame with extracted metrics.
        
    Returns:
        pd.DataFrame: Aggregated metrics.
    """
    hourly_data = df.set_index('timestamp').resample('h').agg({
        'tokens': 'sum',
        'time': ['mean', 'count'],
        'http_errors': 'sum',
        'cuda_errors': 'sum',
        'model_id': lambda x: x.mode()[0] if len(x) > 0 else 'Unknown'
    })
    hourly_data.columns = ['total_tokens', 'avg_time_per_request', 'num_requests', 'http_errors', 'cuda_errors', 'model_id']
    hourly_data['total_requests'] = hourly_data['num_requests'].cumsum()
    return hourly_data

def display_table(df, model_id):
    """
    Displays the DataFrame in a table format using csvlook.
    
    Args:
        df (pd.DataFrame): DataFrame to display.
        model_id (str): The model ID being used.
    """
    temp_csv = "temp_hourly_metrics.csv"
    df.to_csv(temp_csv, index=True)
    result = subprocess.run(['csvlook', temp_csv], stdout=subprocess.PIPE)
    os.remove(temp_csv)
    table = result.stdout.decode('utf-8')
    
    header = colored(f"\nLLM Model Running: {model_id}\n", 'cyan', attrs=['bold'])
    table_lines = table.splitlines()
    table_lines[0] = colored(table_lines[0], 'blue', attrs=['bold'])  # Column headers
    table_lines[1] = colored(table_lines[1], 'blue')  # Column header separators
    table_lines = [colored(line, 'white') for line in table_lines[2:]]  # Table contents
    table = "\n".join([header, table_lines[0], table_lines[1]] + table_lines[2:])
    print(table)

# Find all log files in the directory
log_files = glob.glob('miner-release/llm-miner*.log')

if not log_files:
    print(colored("No log files found in the 'miner-release' directory.", 'red'))
else:
    # Extract unique miner IDs
    miner_ids = set()
    model_ids = set()
    for file in log_files:
        with open(file, 'r') as f:
            for line in f:
                miner_match = re.search(r'Miner ID: (\S+)', line)
                if miner_match:
                    miner_ids.add(miner_match.group(1))
                model_match = re.search(r'Model ID: (\S+)', line)
                if model_match:
                    model_ids.add(model_match.group(1))

    print(colored(f"\nFound {len(log_files)} log files: for LLM Miner: {', '.join(miner_ids)}\n", 'green'))
    print(colored(f"Parsed {len(log_files)} log entries.\n", 'green'))

    # Parse and combine all log files
    all_data = pd.concat([parse_log_file(file) for file in log_files], ignore_index=True)

    if all_data.empty:
        print(colored("No valid log entries found in the log files.\n", 'red'))
    else:
        print(colored(f"Parsed {len(all_data)} log entries.\n", 'green'))

        # Extract metrics from the combined log data
        metrics_df = extract_metrics(all_data)

        # Aggregate metrics on an hourly basis
        hourly_data = aggregate_metrics(metrics_df)

        # Display the aggregated metrics in a table format
        for model_id in model_ids:
            display_table(hourly_data, model_id)