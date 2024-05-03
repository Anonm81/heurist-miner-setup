**Heurist AI Mining Script**

This script is designed to automate the setup and configuration of LLM (Language Model) and SD (Stable Diffusion) miners for Heurist AI. It provides a user-friendly interface to guide users through the process of setting up their mining environment based on their system configuration.

**Features**
* Recommends the optimal mining setup based on the system configuration.
* Allows users to choose between recommended or manual setup.
* Retrieves available models https://raw.githubusercontent.com/heurist-network/heurist-models/main/models.json
* Recommends mining setups which are currently receiving Llama & Waifu rewards.
* Configures the mining environment by installing the required packages and dependencies.
* Updates .env file with the provided EVM addresses in the required format.
* Modifies the config.toml file with the num_cuda_devices parameter based on the number of GPUs detected.
* If proceeding with recommended choice, num_child_process and concurrency_soft_limit is auto updated to num_child_process+10 in    
  config.toml.
* Starts the miners in separate tmux panes within a single window for easy monitoring and management.
* When both LLM and SD models are selected, each GPU's LLM Model will wait for LLM mining to start on the previous GPU (Current GPU - 1), after which SD mining will begin once all LLM miners are running. ( To avoid failures for LLM mining )
* When only SD mining is selected, subsequent SD miners will execute once the download is complete on tmux pane 1
* Waiting for subsequent TMUX panes is achieved via referring the generated log files from LLM miners.
* Update .tmux.conf with alias to monitor tmux sessions 
* Update bashrc file to enable vi mode & mouse scroll mode in TMUX sessions.
* Set alias for tmux attach-session -t miner_monitor as monitor, which can be used to montior the tmux panes

Note: Recommended choices in the script are based on vram requirements from LLM_Miner-starter.sh from Heurist repo

**Prerequisites**
* NVIDIA GPU(s) with CUDA support
* NVIDIA driver installed
* tmux installed (for running miners in separate sessions)

**Usage**
1. Clone the repository using git clone https://github.com/Anonm81/heurist-miner-setup or download the script file.
2. Make the script executable by running chmod +x miner.sh . ( optional )
3. Run the script using sh setup.sh or using ./setup.sh  (latter format requires step 2 to be executed)
4. Enter the EVM address(es) for the miner(s). For multiple GPUs, provide a single address for all GPUs or distinct addresses separated by a comma.
5. Follow the prompts and provide the required inputs:
    * Press 'Y' to continue with the recommended miner setup or 'N' to choose the setup manually.
    * If you choose to proceed with the recommended miner setup, you only need to enter EVM addresses and the script will take care of 
      the rest of the processes.
    * If choosing the setup manually:
        * Select the desired miners to run (LLM + SD, LLM only, or SD only).
        * Choose the LLM model (if applicable).
        * Enter the number of child processes (press Enter to use the default value).
6. Script will install the necessary packages and configure the mining environment based on the selected options.
7. .env file will be updated with the provided EVM addresses in the format MINER_ID_<index>=<address>.
8. If the system has multiple GPUs, the config.toml file will be updated with the num_cuda_devices parameter set to the number of GPUs detected.
9. Once the setup is complete, the script will start the miners in separate tmux sessions.
10. To monitor the miners, use the "monitor" alias.
11. Support for Multi SD Miners on a GPU is now added, you can run upto 3 SD Miners incl SDXL on a 24 GB VRAM.
12. Includes log_analyzer.py which will extract data from your log files.

**TMUX Navigation**
1. Use Ctrl+b followed by arrow keys to move between different TMUX panes
2. Use ctrl+b followed by z to enter full screen
3. Use Ctrl+d followed by d to exit tmux session without aborting the processes.
4. Abort all tmux sessions by tmux kill-session -t miner_monitor. ( If required )
5. Use alias “monitor” to enter the tmux panes
6. If you want to disable vi mode and mouse scroll mode in tmux, delete the ~/.tmux.conf file .

**Variables**
The script currently does not recommend modifying these parameters
* Llama_ratio and SD_ratio: The point weightage for Llama and Waifu models. Currently set at 75:25 , this is just used to recommend models based on your configuration giving weightage to Llama points than waifu points. Nobody knows what the multiplier is.

**Troubleshooting**
* If the script fails to detect the number of GPUs or VRAM correctly, ensure that the NVIDIA driver is properly installed and accessible.
* If the script encounters any errors during the installation or setup process, review the error messages and ensure that the system meets the prerequisites.

**sh setup.sh**
![1w](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/23a7c119-48f4-45e8-be21-90c5c7db9a60)

**Recommended Setup ( Based on available vram )**
![2w](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/a65bd637-6ed2-41b3-91b6-9f63aa943c48)

**Manual setup**
![3w](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/c2e231a9-f9bd-4b4c-b1c8-a3594a660568)
![4w](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/9a420a49-bf20-4653-b5e9-d477032e3798)

**TMUX pane 1 executing LLM miner while pane 2 & 3 wait for LLM to start**
![5](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/d2d85237-bb87-4712-9792-22c7bee19d79)

**LLM Pane 2 Starts once it finds the keyword LLM Miner started on Tmux pane 1**
![6](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/49ddcb0b-8b57-4c5a-a620-c7e916a3f849)

**SD miner Pane 3 Starts once it finds the keyword LLM Miner started on Tmux pane 2**
![7](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/18102a74-0a8b-47cd-8250-99918302189a)

**Optional run python3 log_analyzer.py to analyze your log files**
![8w](https://github.com/Messierig82/Heurist_Miner_Setup/assets/106718401/0e80957e-db57-47cb-89cd-50177ab749a9)




