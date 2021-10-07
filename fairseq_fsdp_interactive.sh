#!/bin/bash

# export MKL_THREADING_LAYER=GNU
# export OMP_NUM_THREADS=20

srun --label \
    --job-name=fairseq-fsdp \
    --nodes=8 \
    --gpus=64 \
    --cpus-per-task=96 \
    --partition=train \
    --time=24:00:00 \
    fairseq_fsdp.sh

