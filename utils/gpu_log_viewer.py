import re
from collections import defaultdict
from tabulate import tabulate
import os

# Function to parse the log file and aggregate data
def parse_log_file(log_file):
    gpu_data = defaultdict(lambda: defaultdict(list))

    with open(log_file, 'r') as f:
        for line in f:
            match = re.match(r'^(\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\.\d{3}), (\d+), (\d+\.\d+), (\d+\.\d+), (\d+), (\d+), (\d+), (\d+\.\d+),?', line.strip())
            if match:
                timestamp, gpu_id, mem_total, mem_used, num_pids, num_sd_pids, num_llm_pids, mem_free = match.groups()
                date_hour = timestamp[:13].replace('/', '-')  # extract date and hour, replace / with -
                gpu_data[date_hour][int(gpu_id)].append({
                    'mem_total': float(mem_total),
                    'mem_used': float(mem_used),
                    'num_pids': int(num_pids),
                    'num_sd_pids': int(num_sd_pids),
                    'num_llm_pids': int(num_llm_pids),
                    'mem_free': float(mem_free)
                })
    return gpu_data

# Function to calculate metrics and generate the table
def generate_table(gpu_data):
    table_data = []

    for date_hour, gpus in sorted(gpu_data.items()):
        hour_data = []
        for gpu_id, data in sorted(gpus.items()):
            mem_total = data[0]['mem_total']  # assume mem_total is constant per GPU
            avg_mem_used = int(sum(d['mem_used'] for d in data) / len(data))
            num_pids = data[0]['num_pids']  # assume num_pids is constant per GPU per hour
            num_sd_pids = data[0]['num_sd_pids']
            num_llm_pids = data[0]['num_llm_pids']
            avg_mem_free = int(sum(d['mem_free'] for d in data) / len(data))
            min_low_mem = sum(1 for d in data if d['mem_free'] < mem_total * 0.1)

            hour_data.append([
                date_hour.ljust(13), 
                str(gpu_id).center(3), 
                f"{mem_total:.1f}".rjust(8), 
                str(avg_mem_used).rjust(13), 
                str(num_pids).center(9),
                str(num_sd_pids).center(9), 
                str(num_llm_pids).center(9), 
                str(avg_mem_free).rjust(13), 
                str(min_low_mem).center(20)
            ])

        if table_data:
            table_data.append(['-' * 13] + ['-' * 3] + ['-' * 8] + ['-' * 13] + ['-' * 9] + ['-' * 9] + ['-' * 9] + ['-' * 13] + ['-' * 20])  # add horizontal separator
        table_data.extend(hour_data)

    return table_data

# Main function to parse log, generate table, and print it
def main():
    # Determine base directory based on script location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    if os.path.basename(script_dir) == 'utils':
        base_dir = os.path.dirname(script_dir)
    else:
        base_dir = script_dir

    # Define the log file directory
    log_file_dir = os.path.join(base_dir, 'logs')
    os.makedirs(log_file_dir, exist_ok=True)

    # Define the log file path
    log_file = os.path.join(log_file_dir, 'gpu_usage.log')

    gpu_data = parse_log_file(log_file)
    table_data = generate_table(gpu_data)
    
    headers = [
        'Date Hour'.ljust(13), 'GPU'.center(3), 'Total Mem'.center(8), 'Avg Used Mem'.center(13), 
        'Num PIDs'.center(9), 'SD PIDs'.center(9), 'LLM PIDs'.center(9), 'Avg Free Mem'.center(13), 
        'Min <10% Free'.center(20)
    ]
    
    print(tabulate(table_data, headers=headers, tablefmt='psql', stralign="center", numalign="right"))

if __name__ == "__main__":
    main()
