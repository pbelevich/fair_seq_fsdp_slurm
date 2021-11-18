# [WIP] FSDP on GCP

We use terraform to setup SLURM cluster on GCP. 

The original SLURM image may not have the required software(mostly gcc/nvcc compilers), so the first step is to clone the original image and install the software you need. Secondly you'd like to save your work(mostly your python code and dependencies) even if you need to recreate a cluster, so you need to create permanent NFS storage that can be attached to your clusters

## Image

[Create GCP image from SLURM image with custom CUDA and GCC](gcp_image.md)

## NFS

[Create GCP NFS share](gcp_nfs.md) and **get IP address and share name!**

## Cluster = Image + NFS

[Install gcloud](https://cloud.google.com/sdk/docs/install)

[Install terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

Clone fsdp_1T branch [pbelevich/slurm-gcp](https://github.com/pbelevich/slurm-gcp)
```bash
git clone -b fsdp_1T https://github.com/pbelevich/slurm-gcp.git pbelevich-slurm-gcp
```
```bash
cd slurm-gcp/tf/examples/basic
```

**Update `network_storage` sections in `40_a2-highgpu-8g.tfvars` with NFS share IP address and share name**

Initialize terraform once
```bash
terraform init
```
Create cluster
```bash
terraform apply -var-file=40_a2-highgpu-8g.tfvars
```


Make sure that CUDA version corresponds to PyTorch CUDA version. The following command should show 11.3.1 if we use PyTorch 1.10 with CUDA toolkit 11.3.1
```bash
nvcc --version
```

## Pythonic Software installation

Run the following commands in the same directory (I used `${HOME}` directory which is mounted to NFS share)

### Download conda installer and run it
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b
${HOME}/miniconda3/bin/conda init bash
. ~/.bash_profile
```

### Install PyTorch 1.10(with CUDA toolkit 11.3.1)
```bash
conda install -y pytorch cudatoolkit=11.3 -c pytorch -c nvidia
conda install -y numpy
```

### Install fairscale
```bash
git clone https://github.com/pbelevich/fairscale.git pbelevich-fairscale
cd pbelevich-fairscale
pip install -q -e .
cd ..
```

### Install fairseq
```bash
git clone -b fsdp_1T_canary https://github.com/pbelevich/fairseq.git pbelevich-fairseq
cd pbelevich-fairseq
pip install -q -e .
cd ..
```

### Install deepspeed
```bash
pip install -q deepspeed
```

### Install apex

Important: this step requires:
1) updated pip
2) gcc version 6+ (I used gcc 7)
3) nvcc version must be the same as CUDA verssion of PyTorch (11.3.1 for PyTorch 1.10)
4) TORCH_CUDA_ARCH_LIST must corresponds to you GPU (8.0 for A100)
```bash
pip install -q --upgrade pip
export TORCH_CUDA_ARCH_LIST=8.0
```
```bash
git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" \
  --global-option="--deprecated_fused_adam" --global-option="--xentropy" \
  --global-option="--fast_multihead_attn" ./
cd ..
```

