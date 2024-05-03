import subprocess
from datetime import datetime, timedelta
import os
import re
import sys 

# Install package for prettytable
def install_package(package):
    try:
        # Open a handle to /dev/null
        with open(os.devnull, 'w') as devnull:
            # Run pip install with the package name, stderr redirected to /dev/null
            subprocess.run([sys.executable, "-m", "pip", "install", package, "-q"], check=True, stderr=devnull)
    except subprocess.CalledProcessError as e:
        print(f"Error installing package {package}: {str(e)}")
    except Exception as e:
        print(f"Unexpected error during package installation: {str(e)}")


# Call install_package function to ensure 'prettytable' is installed before importing it.
install_package("prettytable")

from prettytable import PrettyTable

#Get IP Address
try:
    public_ip = subprocess.check_output("curl -s ipinfo.io/ip", shell=True).decode().strip()
except subprocess.CalledProcessError:
    public_ip = "Unknown"

def find_miner_release_folder():
    for root, dirs, files in os.walk('/'):
        if 'miner-release' in dirs:
            return os.path.join(root, 'miner-release')
    return None

def calculate_percentage_near_average(completion_times, avg_time):
    near_avg = [time for time in completion_times if abs(time - avg_time) / avg_time < 0.1]  # 10% threshold
    return len(near_avg) / len(completion_times) * 100 if completion_times else 0

def calculate_llm_metrics(log_file, model_type, gpu_id):
    try:
        with open(log_file, 'r') as file:
            log_content = file.read()
    except FileNotFoundError:
        return None
    except PermissionError:
        return None

    total_tokens = sum(int(x) for x in re.findall(r'Completed processing (\d+)', log_content))
    total_requests = log_content.count('Completed processing')
    total_time = sum(float(x) for x in re.findall(r'Time: (\d+\.\d+)', log_content))
    tokens_per_second = [float(x) for x in re.findall(r'Tokens/s: (\d+\.\d+)', log_content)]
    completion_times = [float(x) for x in re.findall(r'Time: (\d+\.\d+)', log_content)]

    avg_tokens_per_request = total_tokens / total_requests if total_requests > 0 else 0
    avg_time_per_request = total_time / total_requests if total_requests > 0 else 0
    avg_tokens_per_second = total_tokens / total_time if total_time > 0 else 0

    max_tokens_per_second = max(tokens_per_second) if tokens_per_second else 0
    min_tokens_per_second = min(tokens_per_second) if tokens_per_second else 0

    max_time_per_request = max(completion_times) if completion_times else 0
    min_time_per_request = min(completion_times) if completion_times else 0

    start_time_match = re.search(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}', log_content)
    start_time = start_time_match.group() if start_time_match else None
    end_time_match = re.findall(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}', log_content)
    end_time = end_time_match[-1] if end_time_match else None

    if start_time and end_time:
        start_seconds = datetime.strptime(start_time.split(',')[0], '%Y-%m-%d %H:%M:%S').timestamp()
        end_seconds = datetime.strptime(end_time.split(',')[0], '%Y-%m-%d %H:%M:%S').timestamp()
        total_seconds = end_seconds - start_seconds
        hours_active = total_seconds / 3600
    else:
        hours_active = 0

    model_name_match = re.search(r'Model ID: (\w+)', log_content)
    model_name = model_name_match.group(1) if model_name_match else ""

    percentage_near_avg = calculate_percentage_near_average(completion_times, avg_time_per_request)

    return [
        public_ip,
        f"{GPU_MODEL} ({gpu_id})",
        f"{hours_active:.2f}",
        str(total_requests),
        f"{avg_time_per_request:.2f}",
        f"{percentage_near_avg:.2f}%",
        f"{avg_tokens_per_request:.2f}"
    ]

def calculate_sd_metrics(log_file, model_type, gpu_id):
    try:
        with open(log_file, 'r') as file:
            log_content = file.read()
    except FileNotFoundError:
        return None
    except PermissionError:
        return None

    total_requests = log_content.count('Request ID')
    completion_times = [float(x) for x in re.findall(r'completed\. Total time: (\d+\.\d+)', log_content)]
    
    loading_time_pattern = re.compile(r'Loading.*?(\d+\.\d+|\d+)')
    loading_times = [float(match) for match in re.findall(loading_time_pattern, log_content)]
    avg_loading_time = round(sum(loading_times) / len(loading_times), 2) if loading_times else None

    inference_times = [float(x) for x in re.findall(r'Inference: (\d+\.\d+)', log_content)]
    submit_times = [float(x) for x in re.findall(r'Submit: (\d+\.\d+)', log_content)]

    avg_time_per_request = sum(completion_times) / len(completion_times) if completion_times else 0
    max_time_per_request = max(completion_times) if completion_times else 0
    min_time_per_request = min(completion_times) if completion_times else 0
   
    avg_inference_time = sum(inference_times) / len(inference_times) if inference_times else 0
    avg_submit_time = sum(submit_times) / len(submit_times) if submit_times else 0

    start_time_match = re.search(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}', log_content)
    start_time = start_time_match.group() if start_time_match else None
    end_time_match = re.findall(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}', log_content)
    end_time = end_time_match[-1] if end_time_match else None

    if start_time and end_time:
        start_seconds = datetime.strptime(start_time.split(',')[0], '%Y-%m-%d %H:%M:%S').timestamp()
        end_seconds = datetime.strptime(end_time.split(',')[0], '%Y-%m-%d %H:%M:%S').timestamp()
        total_seconds = end_seconds - start_seconds
        hours_active = total_seconds / 3600
    else:
        hours_active = 0

    model_name_match = re.search(r'Model ID: (\w+)', log_content)
    model_name = model_name_match.group(1) if model_name_match else ""

    percentage_near_avg = calculate_percentage_near_average(completion_times, avg_time_per_request)

    # Calculate requests processed in the last hour
    one_hour_ago = datetime.now() - timedelta(hours=1)
    recent_requests = [time for time in re.findall(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}),\d{3} - root - INFO - Request ID', log_content) if datetime.strptime(time, '%Y-%m-%d %H:%M:%S') > one_hour_ago]
    num_requests_last_hour = len(recent_requests)

    pattern = r"(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}) - root - INFO - Request ID (\S+) completed"
    matches = re.findall(pattern, log_content)

    # Parse datetime from the first match (most recent completion)
    if matches:
        last_request_time = datetime.strptime(matches[-1][0], '%Y-%m-%d %H:%M:%S,%f')
        current_time = datetime.now()
        time_since_last_request = current_time - last_request_time
    else:
        time_since_last_request = "-"

    return [
        
        f"{GPU_MODEL} ({gpu_id})",
        f"{hours_active:.2f}",
        str(total_requests),
        f"{avg_time_per_request:.2f}",
        f"{percentage_near_avg:.2f}%",
        f"{avg_loading_time:.2f}" if avg_loading_time else "-",
        f"{avg_inference_time:.2f}",
        f"{num_requests_last_hour:.2f}",
        time_since_last_request
    ]

# Get GPU model and number of GPUs using nvidia-smi
try:
    gpu_info = subprocess.check_output("nvidia-smi --query-gpu=name,count --format=csv,noheader", shell=True).decode().strip()
    gpu_info_lines = gpu_info.split('\n')
    
    if len(gpu_info_lines) >= 1:
        GPU_MODEL_FULL = gpu_info_lines[0].split(', ')[0]
        NUM_GPUS = len(gpu_info_lines)
    else:
        GPU_MODEL_FULL = "Unknown"
        NUM_GPUS = 0
    
    # Use regex to find the RTX followed by a number with more than three digits
    match = re.search(r'RTX\s(\d{3,})', GPU_MODEL_FULL)
    if match:
        # If a match is found, format it as 'RTX {number}'
        GPU_MODEL = f"RTX {match.group(1)}"
    else:
        # If no such pattern is found, fall back to another part of the name or handle the case
        GPU_MODEL = "Unknown Model"  # Or some other fallback logic
        
except subprocess.CalledProcessError:
    print("Error: Unable to retrieve GPU information using nvidia-smi.")
    exit(1)
except Exception as e:
    print(f"An error occurred: {e}")
    exit(1)


# Find the miner-release folder
miner_release_folder = find_miner_release_folder()
if not miner_release_folder:
    print("Error: miner-release folder not found.")
    exit(1)

# Read miner IDs from .env file
env_file = os.path.join(miner_release_folder, ".env")
with open(env_file, 'r') as file:
    env_content = file.read()

miner_ids = re.findall(r'MINER_ID_(\d+)=(\w+)', env_content)

print("Analyzing mining log files...\n")


# Process LLM and SD logs separately and create different headers for each
llm_headers = ["IP Addr","GPU Model", "Hours (n)", "Requests (n)", "Avg Time/Req", "Avg Req %", "Avg Tokens/Req"]
sd_headers = ["GPU Model", "Hours (n)", "Requests (n)", "Avg Time/Req", "Avg Req %", "Avg Loading Time", "Avg Inference Time", "Requests/Last Hour", "Last Req Processed"]

llm_metrics_data = []
sd_metrics_data = []

for gpu_id, miner_id in miner_ids:
    gpu_uuid = subprocess.check_output(f"nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx={gpu_id} '$1 == idx {{print substr($2, 5, 6)}}'", shell=True).decode().strip()

    llm_log_file = os.path.join(miner_release_folder, f"llm-miner_{miner_id}-{gpu_uuid}.log")
    llm_metrics = calculate_llm_metrics(llm_log_file, "LLM",gpu_id)
    if llm_metrics:
        llm_metrics_data.append(llm_metrics)

    sd_log_file = os.path.join(miner_release_folder, f"sd-miner_{gpu_id}_{miner_id}-{gpu_uuid}.log")
    sd_metrics = calculate_sd_metrics(sd_log_file, "SD",gpu_id)
    if sd_metrics:
        sd_metrics_data.append(sd_metrics)


# Only create and print tables if data exists
if llm_metrics_data:
    miner_ids_str = ", ".join(miner_id for _, miner_id in miner_ids)
    print(f"Language Model (LLM) Mining Metrics (Miner IDs: {miner_ids_str}):\n")
    llm_table = PrettyTable()
    llm_table.field_names = llm_headers
    for row in llm_metrics_data:
        llm_table.add_row(row)
    print(llm_table)
else:
    print("*LLM Miner not active")

if sd_metrics_data:
    sd_table = PrettyTable()
    sd_table.field_names = sd_headers
    for row in sd_metrics_data:
        sd_table.add_row(row)
    print("\nStable Diffusion (SD) Mining Metrics:")
    print(sd_table)
else:
    print("*SD Miner not active")
