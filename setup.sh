#!/usr/bin/env bash

total_vram=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{sum += $1} END {print sum}')
num_gpus=$(nvidia-smi --list-gpus | wc -l)
gpu_model=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)
export start_time=$(date +%s)
WD=$(pwd)
evm_addresses=""
evm_address=""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'  # Red Color
NC='\033[0m' # No Color

# Define box drawing characters
HORIZONTAL_LINE="─"
VERTICAL_LINE="│"
TOP_LEFT_CORNER="┌"
TOP_RIGHT_CORNER="┐"
BOTTOM_LEFT_CORNER="└"
BOTTOM_RIGHT_CORNER="┘"


# Calculate VRAM per GPU
vram_per_gpu=$((total_vram / num_gpus))
gpu_vram=$(( (total_vram * 97 / 100) / num_gpus / 1024 ))
CONDA_ACTIVATE="source activate /opt/conda/envs/gpu-3-11"
#SD_MINER="$(basename $(find / -type f -name 'sd-miner*.py' -path "*/miner-release/*" -print -quit 2>/dev/null))"
#SD_MINER=""



detect_gpus() 
{
num_gpus=$(nvidia-smi --list-gpus | wc -l)
total_vram=0
vram_info=""

for i in $(seq 0 $((num_gpus - 1))); do
    vram=$(nvidia-smi --id=$i --query-gpu=memory.total --format=csv,noheader,nounits)
    total_vram=$((total_vram + vram))
    vram_info="${vram_info}GPU $i: $vram MiB"
    if [ $i -lt $((num_gpus - 1)) ]; then
        vram_info="${vram_info}, "
    fi
done
}

#Function to print a horizontal line for the main table
print_horizontal_line() 
{
    printf "%s%s%s%s%s%s%s\n" "$TOP_LEFT_CORNER" "${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}""${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}" "${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}" "$TOP_RIGHT_CORNER"
}


#Function to print a horizontal line for the main table
print_horizontal_line_llm() 
{
    printf "%s%s%s%s%s%s%s\n" "$TOP_LEFT_CORNER" "${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}" "$TOP_RIGHT_CORNER"
}

print_horizontal_line_sd() 
{
    printf "%s%s%s%s%s%s%s\n" "$TOP_LEFT_CORNER" "${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}""${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}" "${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}" "${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}${HORIZONTAL_LINE}" "$TOP_RIGHT_CORNER"
}
    generate_ascii_art() {
   echo "${BLUE}"
    local text="$1"
    local font="standard"
    local width=80
    

echo "⠀⠀⠀⠀⠀⠀⠀ ⠀⠀     ⠀⠀⣀⣤⣾⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⠀⠀⠀⠀⢰⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"⠀⠀⠀
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿⡿⢿⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⠿⠛⠁⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⣿⡿⠟⠋⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠈⠙⠻⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣤⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢹⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⢀⣀⣀⡀⠀⠀⠀⣀⣀⠀⠀⠀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣸⣿⣿⣿⣀⣀⣀⡀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⣴⣾⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣶⡄⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⣄⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣸⣿⣿⣿⠀⠀⠀⠀⣠⣿⣿⣿⠟⠋⠁⠀⠀⠀⠉⠻⣿⣿⣿⡄⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⣼⡿⠟⠋⠉⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣸⣿⣿⡿⠉⠀⠀⠈⠙⢿⣿⣿⡄⠀⠀⠉⠉⠉⢹⣿⣿⣿⠉⠉⠉⠁⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⣶⣶⣶⣶⡆⠀⠀⠀⠀⣶⣶⣶⣶⡆⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢠⣿⣿⣿⣃⣀⣀⣀⣀⣀⣀⣀⣀⣸⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠹⣿⣿⣷⣤⣀⡀⠀⠀⠈⠉⠉⠁⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⣿⣿⣿⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⢹⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠉⠛⠿⣿⣿⣿⣿⣶⣦⣤⡀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠘⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⣀⣀⡀⠀⠀⠀⠉⠉⠛⢿⣿⣿⣦⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⣿⠁⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠹⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⣠⣾⣿⣿⡟⠀⠀⠀⢹⣿⣿⣿⣄⡀⠀⠀⠀⣀⣴⡿⢹⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠈⣿⣿⣿⣆⡀⠀⠀⠀⠀⣸⣿⣿⣿⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣿⣿⣿⣿⣷⣦⣄⠀⠀⣿⣿⣿⣿⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⢀⣠⣶⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⠟⠀⢸⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠙⠻⢿⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⠀⠀⠀⠀⠀⣿⣿⣿⣿⠀⠀⠀⣀⣤⣾⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠛⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠛⠉⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣤⣴⣿⣿⣿⣿⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⣿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀"
echo "${NC}"
           
}

#Function to print a table
print_gpu_table() {
    local gpu_model="$1"
    local num_gpus="$2"
    local vram_info="$3"
    
    print_horizontal_line
    printf "${BLUE}%s %-50s %s %-20s %s %-20s %s${NC}\n" "$VERTICAL_LINE" "GPU Model" "$VERTICAL_LINE" "Number of GPUs" "$VERTICAL_LINE" "Total VRAM" "$VERTICAL_LINE"
    print_horizontal_line
    printf "${BLUE}%s %-50s %s %-20s %s %-20s %s${NC}\n" "$VERTICAL_LINE" "$gpu_model" "$VERTICAL_LINE" "$num_gpus" "$VERTICAL_LINE" "$vram_info" "$VERTICAL_LINE"
    print_horizontal_line
}

print_rec_table() {
local id="$1"
local llm_model="$2"
local sd_model="$3"
local rewards="$4"
printf "%s %-2s %s %-35s %s %-20s %s %-26s %s${NC}\n" "$VERTICAL_LINE" "$id" "$VERTICAL_LINE" "$llm_model" "$VERTICAL_LINE" "$sd_model" "$VERTICAL_LINE" "$rewards" "$VERTICAL_LINE"
}

print_man_llm_table() {
local id="$1"
local llm_model="$2"
local required_vram="$3"
#printf "%s %-2s %s %-45s %s %-5s %s${NC}\n" "$VERTICAL_LINE" "$id" "$VERTICAL_LINE" "$llm_model" "$VERTICAL_LINE" "$required_vram" "$VERTICAL_LINE"
    # Check if required VRAM exceeds available VRAM
    if awk -v req="$required_vram" -v avail="$vram_per_gpu" 'BEGIN {exit !(req > avail)}'; then
        # Print in red if requirement exceeds availability
        printf "${RED}%s %-2s %s %-45s %s %-5s %s${NC}\n" "$VERTICAL_LINE" "$id" "$VERTICAL_LINE" "$llm_model" "$VERTICAL_LINE" "$required_vram" "$VERTICAL_LINE"
    else
        # Print normally if within limits
        printf "%s %-2s %s %-45s %s %-5s %s${NC}\n" "$VERTICAL_LINE" "$id" "$VERTICAL_LINE" "$llm_model" "$VERTICAL_LINE" "$required_vram" "$VERTICAL_LINE"
    fi
}

print_man_sd_table() {
local id="$1"
local sd_model="$2"
printf "%s %-2s %s %-150s %s${NC}\n" "$VERTICAL_LINE" "$id" "$VERTICAL_LINE" "$sd_model" "$VERTICAL_LINE" 
}

extract_models() {
    json_url="https://raw.githubusercontent.com/heurist-network/heurist-models/main/models.json"
    models=$(curl -s "$json_url")

    # Extract Stable Diffusion models (excluding SDXL) using Python
    sd_models_excl_sdxl=$(echo "$models" | python3 -c "import sys, json; print(','.join([m['name'] for m in json.load(sys.stdin) if m['type'] == 'sd15']))")
    sd_excl_sdxl_vram=$(echo "$models" | python3 -c "import sys, json; print(max([m['size_mb'] for m in json.load(sys.stdin) if m['type'] == 'sd15'])/1024)")

    # Extract Stable Diffusion SDXL models using Python
    sd_models_incl_sdxl=$(echo "$models" | python3 -c "import sys, json; print(','.join([m['name'] for m in json.load(sys.stdin) if m['type'] == 'sdxl10']))")
    sd_incl_sdxl_vram=$(echo "$models" | python3 -c "import sys, json; print(max([m['size_mb'] for m in json.load(sys.stdin) if m['type'] == 'sdxl10'])/1024)")

    # Extract and order LLM models by VRAM consumption using Python
    llm_models_vrams=$(echo "$models" | python3 -c "import sys, json; models = [(m['name'], m['size_gb']) for m in json.load(sys.stdin) if 'llm' in m['type']]; models.sort(key=lambda x: x[1]); print('\n'.join([','.join(map(str, m)) for m in models]))")
}


recommend_models() {
    echo ""

    recommended_choices=""
    llama_multipliers=""
    waifu_multipliers=""
    total_points=""

    # Check Stable Diffusion models
    if awk -v vram="$gpu_vram" -v needed="$sd_excl_sdxl_vram" 'BEGIN {exit !(vram >= needed)}'; then
        waifu_multipliers="5"
    else
        waifu_multipliers="0"
    fi

    if awk -v vram="$gpu_vram" -v needed="$sd_incl_sdxl_vram" 'BEGIN {exit !(vram >= needed)}'; then
        waifu_multipliers="$waifu_multipliers 10"
    else
        waifu_multipliers="$waifu_multipliers 0"
    fi

    # Check LLM models
    i=1
    while IFS= read -r model_vram; do
        model=$(echo "$model_vram" | cut -d',' -f1)
        vram=$(echo "$model_vram" | cut -d',' -f2)
        if awk -v vram="$gpu_vram" -v needed="$vram" 'BEGIN {exit !(vram >= needed)}'; then
            case "$model" in
                "openhermes-2.5-mistral-7b-gptq")
                    llama_multipliers="$llama_multipliers 1"
                    ;;
                "openhermes-2-pro-mistral-7b")
                    llama_multipliers="$llama_multipliers 2"
                    ;;
                "dolphin-2.9-llama3-8b")
                    llama_multipliers="$llama_multipliers 2.5"
                    ;;
                "openhermes-mixtral-8x7b-gptq")
                    llama_multipliers="$llama_multipliers 10"
                    ;;
                *)
                    llama_multipliers="$llama_multipliers 0"
                    ;;
            esac
        else
            llama_multipliers="$llama_multipliers 0"
        fi
        i=$((i + 1))
    done <<EOF
$llm_models_vrams
EOF

    # Find the combination with the maximum total points that fits within the available VRAM
    max_points=0
    max_llm_model=""
    max_sd_model=""

    i=1
    for llama_mult in $llama_multipliers; do
        j=1
        for waifu_mult in $waifu_multipliers; do
            llm_vram=$(echo "$llm_models_vrams" | sed -n "${i}p" | cut -d',' -f2)
            sd_vram=$([ $j -eq 1 ] && echo "$sd_excl_sdxl_vram" || echo "$sd_incl_sdxl_vram")
            if awk -v vram="$gpu_vram" -v needed1="$llm_vram" -v needed2="$sd_vram" 'BEGIN {exit !(vram >= needed1 + needed2)}'; then
                points=$(awk -v lmult="$llama_mult" -v wmult="$waifu_mult" 'BEGIN {printf "%.2f", lmult * 0.76 + wmult * 0.24}')
                if awk -v pts="$points" -v maxpts="$max_points" 'BEGIN {exit !(pts > maxpts)}'; then
                    max_points=$points
                    max_llm_model=$(echo "$llm_models_vrams" | sed -n "${i}p" | cut -d',' -f1)
                    max_sd_model=$([ $j -eq 1 ] && echo "SD Excluding SDXL" || echo "SD Including SDXL")
                fi
            fi
            j=$((j + 1))
        done
        i=$((i + 1))
    done

    if [ -n "$max_llm_model" ] && [ -n "$max_sd_model" ]; then
        echo "${BLUE}Based on available VRAM, recommended miner setup for Llama & Waifu points are:${NC}"
        echo ""
        print_horizontal_line
        printf "${BLUE}%s %-2s %s %-35s %s %-20s %s %-26s %s${NC}\n" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "LLM Model" "$VERTICAL_LINE" "      SD Model" "$VERTICAL_LINE" "        Rewards        " "$VERTICAL_LINE"
        echo "${NC}"
        print_horizontal_line
        print_rec_table "1" "$max_llm_model" "$max_sd_model" "    Llama & Waifu ( 🦙 🧚 )  "
        recommended_choices="llm_model=$max_llm_model,sd_model=$max_sd_model"
    else
        echo "Based on available VRAM, there is not enough VRAM to run both LLM and SD models simultaneously."
        echo "Recommended to run LLM and SD models separately."
        echo ""
    fi

    # Find the LLM model with the highest reward points that fits within the available VRAM
    max_llama_points=0
    max_llama_index=-1
    i=1
    for llama_mult in $llama_multipliers; do
        llm_vram=$(echo "$llm_models_vrams" | sed -n "${i}p" | cut -d',' -f2)
        if awk -v mult="$llama_mult" -v maxmult="$max_llama_points" -v vram="$gpu_vram" -v needed="$llm_vram" 'BEGIN {exit !(mult > maxmult && vram >= needed)}'; then
            max_llama_points=$llama_mult
            max_llama_index=$i
        fi
        i=$((i + 1))
    done

    if [ $max_llama_index -ne -1 ]; then
        max_llama_model=$(echo "$llm_models_vrams" | sed -n "${max_llama_index}p" | cut -d',' -f1)
        echo "\n"
        print_rec_table "2" "$max_llama_model" "" "    Llama ( 🦙 )            "
        recommended_choices="$recommended_choices llm_model=$max_llama_model"
    fi    

    echo "\n"
    if awk -v vram="$gpu_vram" -v needed="$sd_incl_sdxl_vram" 'BEGIN {exit !(vram >= needed)}'; then
        print_rec_table "3" "" "SD Including SDXL" "    Waifu ( 🧚 )            "
        recommended_choices="$recommended_choices sd_model=incl_sdxl"
    elif awk -v vram="$gpu_vram" -v needed="$sd_excl_sdxl_vram" 'BEGIN {exit !(vram >= needed)}'; then
        print_rec_table "3" "" "SD Excluding SDXL" "    Waifu ( 🧚 )             "
        recommended_choices="$recommended_choices sd_model=excl_sdxl"
    fi
    print_horizontal_line
}

set_man_llm_command() {
    i=1
    while IFS= read -r model_vram; do
        if [ "$i" -eq "$manual_llm_choice" ]; then
            selected_llm_model=$(echo "$model_vram" | cut -d',' -f1)
            selected_llm_vram=$(echo "$model_vram" | cut -d',' -f2)
            manual_llm_miner_cmd="./llm-miner-starter.sh $selected_llm_model"
            return
        fi
        i=$((i + 1))
    done <<EOF
$llm_models_vrams
EOF

    echo "Invalid choice. Exiting."
    exit 1
}

miner_setup_choice(){
printf "\n${GREEN}Press 'Y' to continue with the recommended miner setup, Press 'N' to choose setup manually:${NC} "
read user_choice
if [ "$user_choice" = "y" ] || [ "$user_choice" = "Y" ]; then
    printf "\n${GREEN}Enter the corresponding recommended setup: ${NC}"
    read rec_user_choice
    case $rec_user_choice in
        1)
            IFS=',' read -r model_choice_1 model_choice_2 <<EOF
$recommended_choices
EOF
            llm_model=$(echo "$model_choice_1" | cut -d'=' -f2)
            sd_model=$(echo "$model_choice_2" | cut -d'=' -f2)
            rec_llm_miner_cmd="./llm-miner-starter.sh $llm_model"
            if [ "$sd_model" = "excl_sdxl" ]; then
                rec_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG --exclude-sdxl"
            else
                rec_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG"
            fi
            ;;
        2)
           llm_model=$(echo "$recommended_choices" | awk '{print $4}' | cut -d'=' -f2)
            rec_llm_miner_cmd="./llm-miner-starter.sh $llm_model"
            ;;
        3)
            sd_model="incl_sdxl"
            rec_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
    echo "\n${GREEN}The following commands will be executed:\n"
    if [ "$rec_user_choice" = "1" ] || [ "$rec_user_choice" = "2" ]; then
        echo "LLM Miner Command: $rec_llm_miner_cmd"
        if [ "$rec_user_choice" = "1" ]; then
            echo "SD Miner Command will be updated in subsequent steps\n"
        fi
        if [ "$num_gpus" -gt 1 ]; then
            echo "Updating num_child_process to 20, concurrency_soft_limit to 30, NUM_CUDA_DEVICES to $num_gpus"
        else
            echo "Updating num_child_process to 20 and concurrency_soft_limit to 30"
        fi
    else
        echo "Running $(printf "%.0f" "$((gpu_vram / 6))") instances of Stable diffusion miner incl SDXL"
    fi
    sleep 5
    echo "${NC}"

elif [ "$user_choice" = "n" ] || [ "$user_choice" = "N" ]; then
     echo "\n${GREEN}Choose Models to mine: ( 1/2/3 ) \n${NC}"
     print_horizontal_line_llm
     printf "${BLUE}%s %-2s %s %-35s %s ${NC}" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "   Mining Models" 
     echo "${NC}"
     print_horizontal_line_llm
     #print_rec_table "4" "$max_llm_model" "$max_sd_model" "    Llama & Waifu ( 🦙 🧚 )  "

    echo "  1  │   ⛏️ Large Language Model + Stable DIffusion"
    echo "\n  2  │   ⛏️ Large Language Model only"
    echo "\n  3  │   ⛏️ Stable Diffusion only"
    print_horizontal_line_llm

    printf "\n${GREEN}Enter your choice: ${NC}"
    read manual_miner_choice

    case $manual_miner_choice in
        1)
            echo "\n${GREEN}Available Large Language Models: ( 🦙 )\n${NC}"
            echo "${GREEN}Select LLM Model ID followed by SD Miner options:\n${NC}"
            print_horizontal_line_llm
            printf "${BLUE}%s %-2s %s %-40s %s %-5s %s${NC}" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "LLM Mining Models" "$VERTICAL_LINE" "Required VRAM  " "$VERTICAL_LINE"
            echo "${NC}"
            print_horizontal_line_llm
            i=1
            while IFS= read -r model_vram; do
                model=$(echo "$model_vram" | cut -d',' -f1)
                vram=$(echo "$model_vram" | cut -d',' -f2)
                print_man_llm_table "$i " "⛏️ $model" "$vram GB          "
                 echo "\n"
                i=$((i + 1))
            done <<EOF
$llm_models_vrams
EOF
            print_horizontal_line_llm
            printf "\n${GREEN}Choose Heurist LLM Model ID ( 🦙 ) :  ${NC}"
            read manual_llm_choice

            echo "\n${GREEN}Available Stable Diffusion Models: ( 🧚‍♀️ )\n${NC}"
            print_horizontal_line_sd
            printf "${BLUE}%s %-2s %s %-150s %s${NC}" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "Stable Diffusion Mining Models & Required VRAM                                                                                        |" 
            echo "${NC}"
            print_horizontal_line_sd
            print_man_sd_table "1 " "⛏️ SD excl SDXL ($sd_models_excl_sdxl)
                 -- Required VRAM (SD) in GB: $sd_excl_sdxl_vram                                                                                   " 
            echo ""
            print_man_sd_table "2 " "⛏️ SD incl SDXL ($sd_models_incl_sdxl)
                 -- Required VRAM (SD) in GB: $sd_incl_sdxl_vram                                                                                   " 
            print_horizontal_line_sd
            echo ""

            printf "${GREEN}Enter Stable Diffusion Model ID: ${NC}"
            read manual_sd_choice

            
            case $manual_sd_choice in
                1)
                    selected_sd_model="$sd_models_excl_sdxl"
                    selected_sd_vram="$sd_excl_sdxl_vram"
                    ;;
                2)
                    selected_sd_model="$sd_models_incl_sdxl"
                    selected_sd_vram="$sd_incl_sdxl_vram"
                    ;;
                *)
                    echo "Invalid choice. Exiting."
                    exit 1
                    ;;
            esac

            
            #set manual llm command values
            set_man_llm_command

            echo "\n${GREEN}The following commands will be executed:\n${NC}"
            echo "LLM Miner Command: $manual_llm_miner_cmd"
            echo "SD Miner Command will be updated in subsequent steps $manual_sd_miner_cmd"
            ;;

        2)
            echo "\n${GREEN}Available Large Language Models: ( 🦙 )\n${NC}"
            #echo "\n${GREEN}Heurist LLM Models:\n${NC}"
            print_horizontal_line_llm
            #printf "${BLUE}%s %-2s %s %-35s %s ${NC}\n" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "LLM Mining Models" "$VERTICAL_LINE" "Required VRAM " 
            printf "${BLUE}%s %-2s %s %-40s %s %-5s %s${NC}" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "LLM Mining Models" "$VERTICAL_LINE" "Required VRAM  " "$VERTICAL_LINE"
            echo "${NC}"
            print_horizontal_line_llm

            i=1
            while IFS= read -r model_vram; do
                model=$(echo "$model_vram" | cut -d',' -f1)
                vram=$(echo "$model_vram" | cut -d',' -f2)
                #echo "$i) $model"
                #echo "   Required VRAM (LLM) in GB: $vram"
                #echo ""
                print_man_llm_table "$i " "⛏️ $model" "$vram GB          "
                 echo "\n"
                i=$((i + 1))
            done <<EOF
$llm_models_vrams
EOF

            printf "\n${GREEN}Enter Heurist LLM Model ID  ( 🦙 ):${NC} "
            read manual_llm_choice

            #set manual llm command values
            set_man_llm_command 

            echo "${GREEN}The following command will be executed:\n${NC}"
            echo "LLM Miner Command: $manual_llm_miner_cmd"
            ;;

        3)
            echo "\n${GREEN}Heurist Stable Diffusion Model:\n${NC}"
            print_horizontal_line_sd
            printf "${BLUE}%s %-2s %s %-150s %s${NC}" "$VERTICAL_LINE" "ID" "$VERTICAL_LINE" "Stable Diffusion Mining Models & Required VRAM" 
            echo "${NC}"
            print_horizontal_line_sd
            print_man_sd_table "1 " "⛏️ SD excl SDXL ($sd_models_excl_sdxl)
                 -- Required VRAM (SD) in GB: $sd_excl_sdxl_vram                                                                                   " 
            echo ""
            print_man_sd_table "2 " "⛏️ SD incl SDXL ($sd_models_incl_sdxl)
                 -- Required VRAM (SD) in GB: $sd_incl_sdxl_vram                                                                                   " 
            print_horizontal_line_sd
            echo ""

            printf "Enter Stable Diffusion Model ID: "
            read manual_sd_choice

           
            case $manual_sd_choice in
                1)
                    selected_sd_model="$sd_models_excl_sdxl"
                    selected_sd_vram="$sd_excl_sdxl_vram"
                    ;;
                2)  
                    selected_sd_model="$sd_models_incl_sdxl"
                    selected_sd_vram="$sd_incl_sdxl_vram"
                    ;;
                *)
                    echo "Invalid choice. Exiting."
                    exit 1;;
            esac
            if [ "$manual_miner_choice" = "3" ]; then
                while true; do
                    rec_num_sd_miners=$(printf "%.0f" "$((gpu_vram/ 6))")
                   # echo "\n$rec_num_sd_miners SD Miners"
                    
                    printf "${ITALICS}${GREEN}\\nBased on available %d Mib VRAM/GPU you can run upto $rec_num_sd_miners SD miners ( Incl SDXL ) on each GPU. Enter the number of SD miners per GPU (default is 1): ${NC}" "$vram_per_gpu" 
                    
                    read num_sd_miners
                    if [ -z "$num_sd_miners" ]; then
                        num_sd_miners=1
                    break
                    elif ! [ "$num_sd_miners" -ge 0 ] 2>/dev/null; then
                        echo "${RED}Invalid input. Please enter a valid number.${NC}"
                    else
                    break
                    fi
                done
            fi
            
        echo "${GREEN}The following command will be executed:\n${NC}"
        echo "SD Miner Command will be updated in subsequent steps: $manual_sd_miner_cmd";;

        *)
        echo "Invalid choice. Exiting."
        exit 1;;
        esac
else
echo "Invalid choice. Exiting."
exit 1
fi
}


prompt_evm_addresses() {
    echo "${GREEN}"
    echo "${NC}"
    echo "${BLUE}"
    echo "${NC}"

    #Generate Heurist art
    generate_ascii_art

        printf "${BLUE}\\nDetected %s with %d GPUs.\\n${NC}" "$gpu_model" "$num_gpus"
        printf "${BLUE}Your System Configuration is:\\n${NC}"
        print_gpu_table "$gpu_model" "$num_gpus" "$vram_info"
    

        if [ "$num_gpus" -gt 1 ]; then
        #printf "${BLUE}\\nYour instance has $gpu_model with %s GPUs.\\n${NC}" "$num_gpus"
        #printf "${BLUE}\\nYour instance has %s with %d GPUs.\\n${NC}" "$gpu_model" "$num_gpus"

        while true; do
            printf "${ITALICS}${GREEN}\nYour instance has %s GPU's\nTo Continue, Enter a single EVM address for all GPUs or provide %s distinct addresses separated by a comma:${NC}\\n " "$num_gpus" "$num_gpus"
            read evm_addresses
            if [ -z "$evm_addresses" ]; then
                echo "${RED}Error: EVM addresses cannot be empty.${NC}"
            else
                break
            fi
        done

        case "$evm_addresses" in
            *,*)
                num_addresses=$(echo "$evm_addresses" | tr ',' '\n' | wc -l)
                if [ "$num_addresses" -ne "$num_gpus" ]; then
                    printf "Error: The number of provided EVM addresses does not match the number of GPUs (%s).\\n" "$num_gpus" >&2
                    exit 1
                fi
                set -- $(echo "$evm_addresses" | tr ',' ' ')
                i=0
                for address; do
                    eval "address_$i='$address'"
                    i=$(expr "$i" + 1)
                done
                ;;
            *)
                i=0
                while [ "$i" -lt "$num_gpus" ]; do
                    eval "address_$i='$evm_addresses'"
                    i=$(expr "$i" + 1)
                done
                ;;
        esac
    else
        while true; do
            printf "${ITALICS}${GREEN}\\nTo Continue, Please enter your EVM_Address:${NC} "
            read evm_address
            if [ -z "$evm_address" ]; then
                echo "${RED}Error: EVM address cannot be empty.${NC}"
            else
                break
            fi
        done
    fi
}

create_authentication_wallet() {
  echo "${GREEN}Please wait for Identity wallet verification\n\nInstalling Packages required for Wallet Binding generator\n${NC}"
  pip install -q web3 mnemonic python-dotenv prettytable toml > /dev/null 2>&1
  if [ -z "$restart_choice" ] || [ "$restart_choice" = "3" ]; then
        # Clone only if it's a fresh run or cache was deleted
        git clone https://github.com/heurist-network/miner-release > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "An error occurred while trying to clone the repository."
        fi
        echo "${GREEN}\n✓ Miner-Release Repository Cloned \n${NC}"
 elif
         [ "$restart_choice" = "2" ]; then
         echo "${GREEN}\n✓ Skipping Heurist Repository Cloning as miner-release already exists\n${NC}"
fi

echo "${GREEN}Created .env file → Opening .env File for Editing\n${NC}"
touch miner-release/.env

if [ "$num_gpus" -gt 1 ]; then
    case "$evm_addresses" in
        *,*)
            set -- $(echo "$evm_addresses" | tr ',' ' ')
            i=0
            for address; do
                echo "MINER_ID_$i=$address" >> miner-release/.env
                i=$((i + 1))
            done
            ;;
        *)
            i=0
            while [ "$i" -lt "$num_gpus" ]; do
                echo "MINER_ID_$i=$evm_addresses" >> miner-release/.env
              i=$((i + 1))
            done
            ;;
    esac
else
    echo "MINER_ID_0=$evm_address" >> miner-release/.env
fi


    # Read miner IDs from .env file
while IFS='=' read -r key value; do
    case "$key" in
        "MINER_ID_0")
            address_0="$value"
            ;;
        # Add more cases for additional miner IDs if needed
    esac
done < "miner-release/.env"

  mkdir -p /root/.heurist-keys
  echo "${GREEN}.env file created → Running generator for Identity Wallet verification/bonding\n${NC}"
  printf "${BLUE}%*s${NC}\n" $(tput cols) | tr ' ' '*'
  printf "${BLUE}%*s${NC}\n\n" $(tput cols) | tr ' ' '*'
  python3 miner-release/auth/generator.py
  printf "\n${BLUE}%*s${NC}\n" $(tput cols) | tr ' ' '*'
  printf "${BLUE}%*s${NC}\n" $(tput cols) | tr ' ' '*'
}

prompt_config() {
if [ "$user_choice" = "n" ] || [ "$user_choice" = "N" ]; then
    if [ "$manual_miner_choice" = "1" ] || [ "$manual_miner_choice" = "2" ]; then
        printf "${ITALICS}${GREEN}\nIf you want to modify Child Processes, please enter the number, Press Enter to retain the default value: ${NC}"
        read num_child_process
    fi
else
    echo "${GREEN}\nYou have a $gpu_model with $num_gpus GPUs and $vram_info RAM.${NC}"
    if [ "$rec_user_choice" = "1" ]; then
        echo "${GREEN}\nBased on the system resources:Executing "
        echo "$rec_llm_miner_cmd on $num_gpus GPU's followed by $rec_sd_miner_cmd"
    fi
    if [ "$rec_user_choice" = "2" ]; then
        echo "${GREEN}\nBased on the system resources:Executing "
        echo "$rec_llm_miner_cmd on $num_gpus GPU's"
    fi
    if [ "$rec_user_choice" = "3" ]; then
        rec_num_sd_miners=$(printf "%.0f" "$((gpu_vram/ 6))")
        echo "${GREEN}\nBased on the system resources:Executing $rec_num_sd_miners instances of "
        echo "Stable DIffusion $sd_model on $num_gpus GPU's"
        sleep 5
        num_child_process=20
    fi
fi
}
    
update_sd_miner_cmd() 
{

#local sd_model="$1"

#Case logic based on manual_miner_choice and manual_sd_choice
case "$manual_miner_choice" in
    1|3)
        case "$manual_sd_choice" in
            1)
                manual_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG --exclude-sdxl"
                ;;
            2)
                manual_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG"
                ;;
        esac
        ;;
esac

#Case logic based on rec_user_choice and the value of sd_model
case "$rec_user_choice" in
    1)
        if [ "$sd_model" = "excl_sdxl" ]; then
            rec_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG --exclude-sdxl"
        else
            rec_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER") --log-level DEBUG"
        fi
        ;;
    3)
        if [ "$sd_model" = "incl_sdxl" ]; then
            rec_sd_miner_cmd="yes | python3 $(eval echo "$SD_MINER")  --log-level DEBUG"
        fi
        ;;
esac

}

install_stable_diffusion_packages() {
echo "${GREEN}\n✓Installing packages required for Stable Diffusion\n${NC}"
 apt update &&  apt upgrade -y
 if ! command -v nano > /dev/null 2>&1; then
    apt install nano
fi
 if ! command -v tmux > /dev/null 2>&1; then
 apt install tmux -y
fi 
if ! command -v curl > /dev/null 2>&1; then
apt install curl -y
fi 

 #apt-get install python3.8-venv
python3 --version | awk -F'[ .]' '{if ($2 < 3 || ($2 == 3 && $3 < 9)) system("apt-get install -y python3.8-venv")}'

if ! command -v wget > /dev/null 2>&1; then
apt install wget
fi 

echo "${GREEN}✓ Packages Updated → Creating New Conda Environment${NC}"

conda create --name gpu-3-11 python=3.11 -y
echo "${GREEN}\n✓ New Conda Environment Created → Initializing Conda\n${NC}"

eval "$(conda shell.posix hook)"
echo "${GREEN}\n✓ Conda Initialized → Activating Conda Environment\n${NC}"


conda activate /opt/conda/envs/gpu-3-11
echo "${GREEN}\n✓ Conda Environment Activated → Navigating to miner-release\n${NC}"


cd miner-release/
echo "${GREEN}\n✓ Directory Changed to Miner-Release → Creating .env File\n${NC}"


#Find location of config.toml
CONFIG_FILE=$(find . -type f -name "config.toml"  -print -quit 2>/dev/null)

pip install python-dotenv
   
#Find .py file for exectuting SD Miner
SD_MINER="$(basename $(find . -type f -name 'sd-miner*.py'  -print -quit 2>/dev/null))"


#Updating SD miner commands
update_sd_miner_cmd 

if [ "$restart_choice" = "2" ]; then
rm -rf .env 
fi 

echo "${GREEN}\n✓ .env File Updated with EVM_Address → Installing Requirements\n${NC}"

yes | pip install -r requirements.txt
echo "${GREEN}\n✓ Requirements Installed\n${NC}"

sed -i "s/^num_cuda_devices =.*/num_cuda_devices = $num_gpus/" "$CONFIG_FILE"
if [ -n "$num_child_process" ]; then
    sed -i "s/^num_child_process =.*/num_child_process = $num_child_process/" "$CONFIG_FILE"
    sed -i "s/^concurrency_soft_limit =.*/concurrency_soft_limit = $((num_child_process + 10))/" "$CONFIG_FILE"
fi
echo "${GREEN}\nUpdated num_child_process and concurrency_soft_limit in .env file and num_cuda_devices in config.toml.\n${NC}"
}

install_llm_packages() {
echo "${GREEN}\nInstalling Packages required for LLM Miner\n${NC}"
 apt update -y &&  apt install -y jq
echo "${GREEN}\n✓ jq Installed → Installing bc\n${NC}"
 apt install -y bc

echo "${GREEN}\n✓ bc Installed → Updating Packages\n${NC}"

 apt update -y &&  apt upgrade -y &&  apt install -y software-properties-common &&  add-apt-repository ppa:deadsnakes/ppa << EOF

EOF
 apt install -y python3-venv
echo "${GREEN}\n✓ Dependencies Installed for LLM Miner\n${NC}"

#Remove logs for restartability 
#rm -rf llm-miner_*log 2>/dev/null
#rm -rf sd-miner_0_*log 2>/dev/null


}

run_miners() {

    tmux new-session -d -s miner_monitor

    if [ "$user_choice" = "n" ] || [ "$user_choice" = "N" ]; then
        if [ "$manual_miner_choice" = "1" ] || [ "$manual_miner_choice" = "2" ] ; then
            for i in $(seq 0 $((num_gpus - 1))); do
                gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx="$i" '$1 == idx {print substr($2, 5, 6)}')
                miner_id=$(eval echo "\$address_$i")
                log_file="llm-miner_${miner_id}-${gpu_uuid}.log"

            if [ "$i" -eq 0 ]; then
                tmux send-keys -t miner_monitor "$manual_llm_miner_cmd --miner-id-index $i --port 800$i --gpu-ids $i" C-m
            else
                tmux split-window -v -t miner_monitor
                tmux select-layout -t miner_monitor tiled
                prev_gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx="$((i-1))" '$1 == idx {print substr($2, 5, 6)}')
                prev_miner_id=$(eval echo "\$address_$((i-1))")
                prev_log_file="llm-miner_${prev_miner_id}-${prev_gpu_uuid}.log"
                tmux send-keys -t miner_monitor.$((i)) "while true; do if [ -f \"$prev_log_file\" ]; then last_line=\$(grep -a \"LLM miner started\" \"$prev_log_file\" | tail -1); if [ -n \"\$last_line\" ]; then timestamp=\$(echo \"\$last_line\" | awk '{print \$1 \" \" \$2}'); if [ \"\$(date -d \"\$timestamp\" +%s)\" -ge \"\$start_time\" ]; then break; else sleep 1; fi; else sleep 1; fi; else sleep 1; fi; done" C-m
                tmux send-keys -t miner_monitor.$((i)) "clear;echo 'Waiting for LLM to start in GPU $((i-1))...'" C-m
                tmux send-keys -t miner_monitor.$((i)) "echo 'LLM started in GPU $((i-1)). Starting LLM in GPU $i...'" C-m
                tmux send-keys -t miner_monitor.$((i)) "$manual_llm_miner_cmd --miner-id-index $i --port 800$i --gpu-ids $i" C-m
            fi
                pane_index=$((pane_index + 1))
            done
            
            if [ "$manual_miner_choice" = "1" ] ; then
                tmux split-window -v -t miner_monitor
                tmux select-layout -t miner_monitor tiled
                last_pane_index=$num_gpus
                if [ "$num_gpus" -eq 1 ]; then
                    gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' '$1 == 0 {print substr($2, 5, 6)}')
                    miner_id="$evm_address"
                else
                    gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx="$((last_pane_index-1))" '$1 == idx {print substr($2, 5, 6)}')
                    miner_id=$(eval echo "\$address_$((last_pane_index-1))")
                fi
                log_file="llm-miner_${miner_id}-${gpu_uuid}.log"
                tmux send-keys -t miner_monitor.$((last_pane_index)) "while true; do if [ -f \"$log_file\" ]; then last_line=\$(grep -a \"LLM miner started\" \"$log_file\" | tail -1); if [ -n \"\$last_line\" ]; then timestamp=\$(echo \"\$last_line\" | awk '{print \$1 \" \" \$2}'); if [ \"\$(date -d \"\$timestamp\" +%s)\" -ge \"\$start_time\" ]; then break; else sleep 1; fi; else sleep 1; fi; else sleep 1; fi; done" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "clear;echo 'Waiting for LLM to start in GPU $((last_pane_index-1))...'" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "echo 'LLM started in GPU $((last_pane_index-1)). Starting SD Miner...'" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "$CONDA_ACTIVATE" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "$manual_sd_miner_cmd" C-m
            fi
        elif [ "$manual_miner_choice" = "3" ]; then
            miner_id_0="${address_0}"
            gpu_uuid_0=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' '$1 == 0 {print substr($2, 5, 6)}')
            log_file="sd-miner_0_${miner_id_0}-${gpu_uuid_0}.log"
            for i in $(seq 1 $((num_sd_miners))); do
            if [ "$i" -eq 1 ]; then
                tmux send-keys -t miner_monitor "$CONDA_ACTIVATE" C-m
                tmux send-keys -t miner_monitor "$manual_sd_miner_cmd" C-m
            else
                tmux split-window -v -t miner_monitor
                tmux select-layout -t miner_monitor tiled

                tmux send-keys -t miner_monitor.$((i-1)) "while true; do if [ -f \"$log_file\" ]; then last_line=\$(grep -a \"Default model .* loaded successfully\" \"$log_file\" | tail -1); if [ -n \"\$last_line\" ]; then timestamp=\$(echo \"\$last_line\" | awk '{print \$1 \" \" \$2}'); if [ \"\$(date -d \"\$timestamp\" +%s)\" -ge \"\$start_time\" ]; then break; else sleep 1; fi; else sleep 1; fi; else sleep 1; fi; done" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "echo \"Last line that caused exit: \$last_line\"" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "clear;echo 'Waiting for SD Miner to start in GPU 0...'" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "echo 'SD Miner started in GPU 0. To avoid resource contention starting SD Miner $i in 20 seconds...'" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "sleep 20" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "$CONDA_ACTIVATE" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "$manual_sd_miner_cmd" C-m
            fi
            done
        fi
    else
        if [ "$rec_user_choice" = "1" ] || [ "$rec_user_choice" = "2" ] ; then
            for i in $(seq 0 $((num_gpus - 1))); do
                gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx="$i" '$1 == idx {print substr($2, 5, 6)}')
                miner_id=$(eval echo "\$address_$i")
                log_file="llm-miner_${miner_id}-${gpu_uuid}.log"
                if [ "$i" -eq 0 ]; then
                    tmux send-keys -t miner_monitor "$rec_llm_miner_cmd --miner-id-index $i --port 800$i --gpu-ids $i" C-m
                else
                    tmux split-window -v -t miner_monitor
                    tmux select-layout -t miner_monitor tiled
                    prev_gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx="$((i-1))" '$1 == idx {print substr($2, 5, 6)}')
                    prev_miner_id=$(eval echo "\$address_$((i-1))")
                    prev_log_file="llm-miner_${prev_miner_id}-${prev_gpu_uuid}.log"
                    tmux send-keys -t miner_monitor.$((i)) "while true; do if [ -f \"$prev_log_file\" ]; then last_line=\$(grep -a \"LLM miner started\" \"$prev_log_file\" | tail -1); if [ -n \"\$last_line\" ]; then timestamp=\$(echo \"\$last_line\" | awk '{print \$1 \" \" \$2}'); if [ \"\$(date -d \"\$timestamp\" +%s)\" -ge \"\$start_time\" ]; then break; else sleep 1; fi; else sleep 1; fi; else sleep 1; fi; done" C-m
                    tmux send-keys -t miner_monitor.$((i)) "clear;echo 'Waiting for LLM to start in GPU $((i-1))...'" C-m
                    tmux send-keys -t miner_monitor.$((i)) "echo 'LLM started in GPU $((i-1)). Starting LLM in GPU $i...'" C-m
                    tmux send-keys -t miner_monitor.$((i)) "$rec_llm_miner_cmd --miner-id-index $i --port 800$i --gpu-ids $i" C-m
                fi
            pane_index=$((pane_index + 1))
            done

            if [ "$rec_user_choice" = "1" ] ; then
                tmux split-window -v -t miner_monitor
                tmux select-layout -t miner_monitor tiled
                last_pane_index=$num_gpus
                if [ "$num_gpus" -eq 1 ]; then
                    gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' '$1 == 0 {print substr($2, 5, 6)}')
                    miner_id="$evm_address"
                else
                    gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' -v idx="$((last_pane_index-1))" '$1 == idx {print substr($2, 5, 6)}')
                    miner_id=$(eval echo "\$address_$((last_pane_index-1))")
                fi
                log_file="llm-miner_${miner_id}-${gpu_uuid}.log"
                
                tmux send-keys -t miner_monitor.$((last_pane_index)) "while true; do if [ -f \"$log_file\" ]; then last_line=\$(grep -a \"LLM miner started\" \"$log_file\" | tail -1); if [ -n \"\$last_line\" ]; then timestamp=\$(echo \"\$last_line\" | awk '{print \$1 \" \" \$2}'); if [ \"\$(date -d \"\$timestamp\" +%s)\" -ge \"\$start_time\" ]; then break; else sleep 1; fi; else sleep 1; fi; else sleep 1; fi; done" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "clear;echo 'Waiting for LLM to start in GPU $((last_pane_index-1))...'" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "echo 'LLM started in GPU $((last_pane_index-1)). Starting SD Miner...'" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "$CONDA_ACTIVATE" C-m
                tmux send-keys -t miner_monitor.$((last_pane_index)) "$rec_sd_miner_cmd" C-m
            fi
        elif [ "$rec_user_choice" = "3" ]; then
            rec_num_sd_miners=$(printf "%.0f" "$((gpu_vram/ 6))")
            for i in $(seq 1 $((rec_num_sd_miners))); do
            if [ "$i" -eq 1 ]; then
                tmux send-keys -t miner_monitor "$CONDA_ACTIVATE" C-m
                tmux send-keys -t miner_monitor "$rec_sd_miner_cmd" C-m
            else
                tmux split-window -v -t miner_monitor
                tmux select-layout -t miner_monitor tiled
                gpu_uuid=$(nvidia-smi --query-gpu=index,uuid --format=csv,noheader | awk -F', ' '$1 == 0 {print substr($2, 5, 6)}')
                miner_id_0="${address_0}"
                log_file="sd-miner_0_${miner_id_0}-${gpu_uuid}.log"

                tmux send-keys -t miner_monitor.$((i-1)) "while true; do if [ -f \"$log_file\" ]; then last_line=\$(grep -a \"Default model .* loaded successfully\" \"$log_file\" | tail -1); if [ -n \"\$last_line\" ]; then timestamp=\$(echo \"\$last_line\" | awk '{print \$1 \" \" \$2}'); if [ \"\$(date -d \"\$timestamp\" +%s)\" -ge \"\$start_time\" ]; then break; else sleep 1; fi; else sleep 1; fi; else sleep 1; fi; done" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "clear;echo 'Waiting for SD Miner to start in GPU 0...'" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "echo 'SD Miner started in GPU 0. To avoid resource contention starting SD Miner $i in 20 seconds...'" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "sleep 20" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "$CONDA_ACTIVATE" C-m
                tmux send-keys -t miner_monitor.$((i-1)) "$rec_sd_miner_cmd" C-m
            fi
            done
        fi
    fi

tmux attach-session -t miner_monitor
}

save_user_choices() {
    echo "user_choice=$user_choice" > "$CHOICES_FILE_PATH"
    echo "num_gpus=$num_gpus" >> "$CHOICES_FILE_PATH"
    echo "address_0=$address_0" >> "$CHOICES_FILE_PATH"
    echo "CONDA_ACTIVATE=$CONDA_ACTIVATE" >> "$CHOICES_FILE_PATH"
    echo "start_time=$start_time" >> "$CHOICES_FILE_PATH"
    echo "WD='$WD'" >> "$CHOICES_FILE_PATH"
    echo "SD_MINER='$SD_MINER'" >> "$CHOICES_FILE_PATH"
    echo "evm_address=$evm_address">> "$CHOICES_FILE_PATH"
    if [ "$num_gpus" -gt 1 ]; then
        for i in $(seq 1 $((num_gpus - 1))); do
            echo "address_$i='$(eval echo "\$address_$i")'" >> "$CHOICES_FILE_PATH"
        done
    fi

 # Conditional section based on user choice
    if [ "$user_choice" = "n" ] || [ "$user_choice" = "N" ]; then
        [ -n "$manual_miner_choice" ] && echo "manual_miner_choice=$manual_miner_choice" >> "$CHOICES_FILE_PATH"
        [ -n "$manual_llm_choice" ] && echo "manual_llm_choice=$manual_llm_choice" >> "$CHOICES_FILE_PATH"
        [ -n "$manual_sd_choice" ] && echo "manual_sd_choice=$manual_sd_choice" >> "$CHOICES_FILE_PATH"
        [ -n "$num_child_process" ] && echo "num_child_process=$num_child_process" >> "$CHOICES_FILE_PATH"
        [ -n "$num_sd_miners" ] && echo "num_sd_miners=$num_sd_miners" >> "$CHOICES_FILE_PATH"
        [ -n "$manual_llm_miner_cmd" ] && echo "manual_llm_miner_cmd=\"$manual_llm_miner_cmd\"" >> "$CHOICES_FILE_PATH"
        [ -n "$manual_sd_miner_cmd" ] && echo "manual_sd_miner_cmd=\"$manual_sd_miner_cmd\"" >> "$CHOICES_FILE_PATH"
    else
        [ -n "$rec_user_choice" ] && echo "rec_user_choice=$rec_user_choice" >> "$CHOICES_FILE_PATH"
        [ -n "$rec_llm_miner_cmd" ] && echo "rec_llm_miner_cmd=\"$rec_llm_miner_cmd\"" >> "$CHOICES_FILE_PATH"
        [ -n "$rec_sd_miner_cmd" ] && echo "rec_sd_miner_cmd=\"$rec_sd_miner_cmd\"" >> "$CHOICES_FILE_PATH"
        [ -n "$rec_num_sd_miners" ] && echo "rec_num_sd_miners=$rec_num_sd_miners" >> "$CHOICES_FILE_PATH"
    fi
    
    echo "gpu_vram=$gpu_vram" >> "$CHOICES_FILE_PATH"
}

set_path() {
    if [ "$WD" = "/" ]; then
        CHOICES_FILE_PATH="${WD}user_choices.txt"  # Directly append to avoid double slash
    else
        CHOICES_FILE_PATH="${WD}/user_choices.txt"
    fi
}

update_tmux_bashrc_conf() {
if [ -f ~/.tmux.conf ]; then
    grep -q 'setw -g mode-keys vi' ~/.tmux.conf || echo 'setw -g mode-keys vi' >> ~/.tmux.conf
    grep -q 'set -g status-keys vi' ~/.tmux.conf || echo 'set -g status-keys vi' >> ~/.tmux.conf
    grep -q 'set -g mouse on' ~/.tmux.conf || echo 'set -g mouse on' >> ~/.tmux.conf
else
    echo 'setw -g mode-keys vi' >> ~/.tmux.conf
    echo 'set -g status-keys vi' >> ~/.tmux.conf
    echo 'set -g mouse on' >> ~/.tmux.conf
fi

if ! grep -q "alias monitor='tmux attach-session -t miner_monitor'" ~/.bashrc; then
    echo "alias monitor='tmux attach-session -t miner_monitor'" >> ~/.bashrc

fi

}

main(){
        export start_time=$(date +%s)
        detect_gpus
        extract_models
        prompt_evm_addresses
        create_authentication_wallet
        recommend_models
        miner_setup_choice
        prompt_config
        install_stable_diffusion_packages
        install_llm_packages
        update_tmux_bashrc_conf
        save_user_choices
        run_miners 
}

delete_cache_folders() {
        tmux kill-session -t miner_monitor
        rm -rf ~/.cache/huggingface/ 
        rm -rf ~/.cache/heurist/
        rm -rf "miner-release"
        rm -rf "$CHOICES_FILE_PATH"
}

restart_miners() {
        export start_time=$(date +%s)
        if tmux has-session -t miner_monitor 2>/dev/null; then
            tmux kill-session -t miner_monitor
            echo "${GREEN}TMUX Session 'miner_monitor' terminated${NC}"
        else
            echo "${GREEN}miner_monitor does not exist,skipping TMUX termination${NC}"
        fi
        echo "TMUX Session exited, Sleep for 20 seconds to wait for resource unlocks..."
        #sleep 20
        save_user_choices
        echo "User choices updated"
        eval "$(conda shell.posix hook)"
        conda activate /opt/conda/envs/gpu-3-11
        echo "Conda environment activated"
        cd miner-release/
        echo "Navigating to miner-release"
        run_miners
}
#Call Functions

set_path

if [ -f "$CHOICES_FILE_PATH" ]; then
    # Load values
    execution_mode='Restart'
    . "$CHOICES_FILE_PATH"
    echo "\n${YELLOW}!Existing Mining setup detected: ${NC}"
    
    if [ "$user_choice" = "n" ] || [ "$user_choice" = "N" ]; then
        echo "\n${GREEN}Previous manual mining setup choice:\n${BLUE}"
        [ -n "$manual_miner_choice" ] && echo "Miner Choice: $manual_miner_choice"
        [ -n "$manual_llm_choice" ] && echo "LLM Choice: $manual_llm_choice"
        [ -n "$manual_sd_choice" ] && echo "SD Choice: $manual_sd_choice"
        [ -n "$num_sd_miners" ] && echo "Number of SD Miners: $num_sd_miners"
        [ -n "$manual_llm_miner_cmd" ] && echo "LLM Miner Command: $manual_llm_miner_cmd"
        [ -n "$manual_sd_miner_cmd" ] && echo "SD Miner Command: $manual_sd_miner_cmd"
    else
        echo "\n${GREEN}Previous recommended mining setup choice:\n${BLUE}"
        [ -n "$rec_user_choice" ] && echo "User Choice: $rec_user_choice"
        [ -n "$rec_llm_miner_cmd" ] && echo "LLM Miner Command: $rec_llm_miner_cmd"
        [ -n "$rec_sd_miner_cmd" ] && echo "SD Miner Command: $rec_sd_miner_cmd"
        [ -n "$rec_num_sd_miners" ] && echo "Number of SD Miners: $rec_num_sd_miners"
    fi

    echo -n "\n${GREEN}Press 1 to continue with the same setup, Press 2 to reconfigure mining setup, Press 3 to delete cache and reinstall: ${NC}"
    read restart_choice
    
    if [ "$restart_choice" = "1" ]; then
        echo "\n${GREEN}Proceeding to restart the above miner setup:${NC}"
        restart_miners
    elif [ "$restart_choice" = "2" ]; then
        if tmux has-session -t miner_monitor 2>/dev/null; then
            tmux kill-session -t miner_monitor
            echo "${GREEN}TMUX Session 'miner_monitor' terminated${NC}"
        else
            echo "${GREEN}miner_monitor does not exist,skipping TMUX termination${NC}"
        fi
        main 
    elif [ "$restart_choice" = "3" ]; then
        echo "\n${GREEN}Deleting Cache, Proceeding to Reconfigure...${NC}"
        delete_cache_folders
        main 
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
else 
    main 
fi
