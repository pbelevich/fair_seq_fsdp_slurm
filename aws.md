# AWS

## Download conda installer and run it
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b
rm Miniconda3-latest-Linux-x86_64.sh
${HOME}/miniconda3/bin/conda init bash
. ~/.bash_profile
```

## Create and activate conda environment
```bash
conda create -yn fsdp_1T python=3.8
conda activate fsdp_1T
echo "conda activate fsdp_1T" >> ${HOME}/.bashrc
```

## Download and install CUDA
```bash
wget https://developer.download.nvidia.com/compute/cuda/11.4.2/local_installers/cuda_11.4.2_470.57.02_linux.run
sudo sh cuda_11.4.2_470.57.02_linux.run --silent --toolkit
rm cuda_11.4.2_470.57.02_linux.run

export PATH=/usr/local/cuda/bin:${PATH}
echo "export PATH=/usr/local/cuda/bin:\${PATH}" >> ${HOME}/.bashrc

export TORCH_CUDA_ARCH_LIST=8.0
echo "export TORCH_CUDA_ARCH_LIST=8.0" >> ${HOME}/.bashrc

. ~/.bash_profile
```

## Install PyTorch build dependencies
```bash
conda install -y astunparse numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses
conda install -y -c pytorch magma-cuda110
```

## Clone PyTorch and install it
```bash
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
srun --nodes 1 --cpus-per-task=96 --gpus 8 python setup.py install
cd ..
```
