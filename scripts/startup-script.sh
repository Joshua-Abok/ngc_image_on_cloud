#!/bin/bash
# runs as root on VM startup
set -euo pipefail

#1. update & install prerequisites
apt-get update 
apt-get install -y \ 
    ca-certificates curl gnupg lsb-release \
    python3-pip

# 2. Install Docker CE  
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
   https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update 
apt-get install -y docker-ce docker-ce-cli containerd.io

# # 2b. Install the NVIDIA GPU driver
# apt-get install -y linux-headers-$(uname -r) nvidia-driver-525
# # verify
# nvidia-smi

# 3. Install NVIDIA Container Toolkit  
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey \
  | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/${distribution}/nvidia-docker.list \
  | tee /etc/apt/sources.list.d/nvidia-docker.list

apt-get update 
apt-get install -y nvidia-docker2
systemctl restart docker 

# 4. allow ubuntu user to run Docker  
usermod -aG docker ubuntu 

# 5. Pull NGC PyTorch image  
docker pull nvcr.io/nvidia/pytorch:24.11-py3

# 6. Launch Jupyter notebook container 
#    - Replace /home/ubuntu/llm-project with project path on persistent disk

# Ensure the project directory exists
if [ ! -d "/llm-project" ]; then
  mkdir -p /llm-project
fi

docker run --gpus all -d --name llm-notebook \
  -v /llm-project:/workspace \
  -p 8888:8888 \
  nvcr.io/nvidia/pytorch:24.11-py3 \
  bash -c "cd /workspace && \
           pip install -r requirements.txt && \
           jupyter lab --ip=0.0.0.0 --no-browser --allow-root"

echo "Startup script complete. Jupyter should be listening on port 8888."