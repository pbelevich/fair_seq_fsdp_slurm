#!/bin/bash

export ENABLE_NCCL_BASE_COLLECTIVES=1

# LAYERS=96
# ATTN=96
# EMBED_DIM=20928

fairseq-train data-bin/wikitext-103 \
        --ddp-backend fully_sharded --fp16 --fp16-init-scale 4 \
        --cpu-offload --checkpoint-activations \
        --task language_modeling --tokens-per-sample 128 --batch-size 1 \
        --arch transformer_lm_gpt3_175 \
        --optimizer cpu_adam --adam-betas "(0.9,0.98)" \
        --lr 0.0001 --lr-scheduler polynomial_decay --warmup-updates 5 --total-num-update 10 \
        --max-update 10 --no-save --log-format json --log-interval 1 \
        --distributed-port 29500 # \
#        --decoder-embed-dim ${EMBED_DIM} \
#        --decoder-output-dim ${EMBED_DIM} \
#        --decoder-input-dim ${EMBED_DIM} \
#        --decoder-ffn-embed-dim $((4*EMBED_DIM)) \
#        --decoder-layers ${LAYERS} \
#        --decoder-attention-heads ${ATTN}

