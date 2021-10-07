#!/bin/bash

#SBATCH --job-name=fairseq-fsdp

#SBATCH --nodes=8

#SBATCH --gpus=64

#SBATCH --cpus-per-task=96

#SBATCH --partition=train

#SBATCH--time=24:00:00

srun --label fairseq_fsdp.sh

