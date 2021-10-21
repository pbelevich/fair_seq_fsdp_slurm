#!/bin/bash

#SBATCH --job-name=fsdp_1T

#SBATCH --open-mode=append

#SBATCH --nodes=8

#SBATCH --gpus=64

#SBATCH --cpus-per-task=80

#SBATCH --partition=train

#SBATCH--time=24:00:00

srun --label fairseq_fsdp.sh
