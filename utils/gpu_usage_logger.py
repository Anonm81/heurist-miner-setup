import subprocess
import time
from datetime import datetime

# Function to query GPU usage and log it
def log_gpu_usage(log_file):
    try:
        # Run nvidia-smi to get GPU utilization and memory usage
        gpu_usage_result = subprocess.run(
            ['nvidia-smi', '--query-gpu=timestamp,index,uuid,utilization.gpu,memory.total,memory.used', '--format=csv,noheader,nounits'],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True
        )
        
        # Run nvidia-smi to get compute apps details
        compute_apps_result = subprocess.run(
            ['nvidia-smi', '--query-compute-apps=gpu_uuid,pid', '--format=csv,noheader,nounits'],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True
        )
        
        # Parse the GPU usage result
        gpu_usage_lines = gpu_usage_result.stdout.strip().split('\n')
        compute_apps_lines = compute_apps_result.stdout.strip().split('\n')
        
        gpu_data = {}
        
        for line in gpu_usage_lines:
            parts = line.split(', ')
            if len(parts) < 6:
                continue
            timestamp, gpu_index, gpu_uuid, gpu_util, mem_total, mem_used = parts
            if gpu_uuid not in gpu_data:
                gpu_data[gpu_uuid] = {
                    'timestamp': timestamp,
                    'gpu_index': gpu_index,
                    'gpu_util': float(gpu_util),
                    'mem_total': float(mem_total),
                    'mem_used': float(mem_used),
                    'num_pids': 0
                }
        
        for line in compute_apps_lines:
            parts = line.split(', ')
            if len(parts) < 2:
                continue
            gpu_uuid, pid = parts
            if gpu_uuid in gpu_data:
                gpu_data[gpu_uuid]['num_pids'] += 1
        
        # Count sd-miner and llm-miner processes
        try:
            sd_miner_count = int(subprocess.run(['pgrep', '-c', '-f', 'sd-miner.*py'],
                                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True).stdout.strip())
        except subprocess.CalledProcessError:
            sd_miner_count = 0

        try:
            llm_miner_count = int(subprocess.run(['pgrep', '-c', '-f', 'llm-miner.*py'],
                                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True).stdout.strip())
        except subprocess.CalledProcessError:
            llm_miner_count = 0

        # Log CPU usage
        cpu_usage_result = subprocess.run(['top', '-b', '-n', '1'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        cpu_usage_line = cpu_usage_result.stdout.split('\n')[2]
        cpu_usage = cpu_usage_line.split(',')[0].split('%')[0].strip().split(' ')[-1]

        # Write to log file
        with open(log_file, 'a') as f:
            for gpu_uuid, data in gpu_data.items():
                free_gpu = data['mem_total'] - data['mem_used']
                f.write(f"{data['timestamp']}, {data['gpu_index']}, {data['mem_total']}, {data['mem_used']}, {data['num_pids']}, {sd_miner_count}, {llm_miner_count}, {free_gpu}, {cpu_usage}\n")
    
    except subprocess.CalledProcessError as e:
        print(f"Error querying GPU usage: {e}")

# Main function to run the logging at regular intervals
def main(log_file='gpu_usage.log', interval=60):
    while True:
        log_gpu_usage(log_file)
        time.sleep(interval)

if __name__ == "__main__":
    main()
