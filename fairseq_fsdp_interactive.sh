#!/bin/bash

export MKL_THREADING_LAYER=GNU
export OMP_NUM_THREADS=20

srun --label \
    --job-name=fairseq-fsdp \
    --nodes=8 \
    --gpus=64 \
    --partition=train \
    --time=24:00:00 \
    fairseq-train data-bin/wikitext-103 \
        --ddp-backend fully_sharded --fp16 --fp16-init-scale 4 \
        --cpu-offload --checkpoint-activations \
        --task language_modeling --tokens-per-sample 2048 --batch-size 8 \
        --arch transformer_lm_gpt3_13 \
        --optimizer cpu_adam --adam-betas "(0.9,0.98)" \
        --lr 0.0001 --lr-scheduler polynomial_decay --warmup-updates 5 --total-num-update 10 \
        --max-update 10 --no-save --log-format json --log-interval 1 \
        --distributed-port 29500 \
        --decoder-embed-dim 6144 \
        --decoder-output-dim 6144 \
        --decoder-input-dim 6144 \
        --decoder-ffn-embed-dim 24576 \
        --decoder-layers 48 \
        --decoder-attention-heads 48

