# Create GCP image from SLURM image with custom CUDA and GCC

Define environment variables:
```bash
export CLUSTER_ZONE="us-central1-b"
export SLURM_IMAGE="slurm-image"
export IMAGE_INSTANCE="${SLURM_IMAGE}-instance"
export PROJECT_NAME="pytorch-distributed"
```

Create new `a2-highgpu-1g` instance with 30GB disk from the original `projects/schedmd-slurm-public/global/images/family/schedmd-slurm-21-08-2-hpc-centos-7` image:
```bash
gcloud compute instances create ${IMAGE_INSTANCE} \
	--machine-type a2-highgpu-1g \
	--zone ${CLUSTER_ZONE} \
	--maintenance-policy TERMINATE \
	--boot-disk-size 30GB \
	--restart-on-failure \
	--image-family schedmd-slurm-20-11-4-hpc-centos-7 \
	--image-project schedmd-slurm-public
```

Wait for a couple of minutes and ssh to this new instance:
```bash
gcloud compute ssh ${IMAGE_INSTANCE} --zone ${CLUSTER_ZONE}
```

Install gcc 7 to the instance:
```bash
sudo yum install -y -q centos-release-scl
sudo yum install -y -q devtoolset-7-gcc*
sudo yum install -y -q scl-utils
source scl_source enable devtoolset-7
```

Double-check that it's gcc 7:
```bash
gcc --version
```

Download and install CUDA 11.3.1(for PyTorch 1.10) or any other that you need for your PyTorch version:
```bash
wget https://developer.download.nvidia.com/compute/cuda/11.3.1/local_installers/cuda_11.3.1_465.19.01_linux.run
mkdir tmp
sudo sh cuda_11.3.1_465.19.01_linux.run --silent --toolkit --tmpdir=$(pwd)/tmp
sudo rm -rf tmp cuda_11.3.1_465.19.01_linux.run
```

Double-check that it's nvcc 11.3.1:
```bash
nvcc --version
```

Exit the box:
```bash
exit
```

Stop the instance:
```bash
gcloud compute instances stop ${IMAGE_INSTANCE}
```

Create new image from the disk of the stopped instance:
```bash
gcloud compute images create ${SLURM_IMAGE} \
  --source-disk=${IMAGE_INSTANCE} \
  --source-disk-zone=${CLUSTER_ZONE}
```

Get the image self link:
```bash
gcloud compute images describe ${SLURM_IMAGE} --format="value(selfLink)"
```
