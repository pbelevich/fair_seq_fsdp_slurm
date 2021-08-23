# Run fairseq-train with SLURM srun

```bash
git clone https://github.com/pbelevich/fair_seq_fsdp_slurm.git
cd fair_seq_fsdp_slurm
```
```bash
conda create -yn fair_seq_fsdp_slurm python=3.8
conda activate fair_seq_fsdp_slurm

conda install pytorch cudatoolkit=11.1 -c pytorch -c nvidia

pip install fairscale

# pip install fairseq will not work as of August 2021, so clone and do pip install from source:
git clone https://github.com/pytorch/fairseq
cd fairseq
pip install --editable ./

pip install deepspeed

git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" \
  --global-option="--deprecated_fused_adam" --global-option="--xentropy" \
  --global-option="--fast_multihead_attn" ./
```
Quick fix [fairseq-deepspeed issue](https://github.com/pytorch/fairseq/issues/3810):
Open fairseq/optim/cpu_adam.py and add `, False` to [the line 116](https://github.com/pytorch/fairseq/blob/1f7ef9ed1e1061f8c7f88f8b94c7186834398690/fairseq/optim/cpu_adam.py#L116)

[Preprocess the data for RoBERTa](https://github.com/pytorch/fairseq/blob/master/examples/roberta/README.pretraining.md#1-preprocess-the-data)
```bash
wget https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-raw-v1.zip
unzip wikitext-103-raw-v1.zip
```
```bash
mkdir -p gpt2_bpe
wget -O gpt2_bpe/encoder.json https://dl.fbaipublicfiles.com/fairseq/gpt2_bpe/encoder.json
wget -O gpt2_bpe/vocab.bpe https://dl.fbaipublicfiles.com/fairseq/gpt2_bpe/vocab.bpe
for SPLIT in train valid test; do \
    python -m examples.roberta.multiprocessing_bpe_encoder \
        --encoder-json gpt2_bpe/encoder.json \
        --vocab-bpe gpt2_bpe/vocab.bpe \
        --inputs wikitext-103-raw/wiki.${SPLIT}.raw \
        --outputs wikitext-103-raw/wiki.${SPLIT}.bpe \
        --keep-empty \
        --workers 60; \
done
```
```bash
wget -O gpt2_bpe/dict.txt https://dl.fbaipublicfiles.com/fairseq/gpt2_bpe/dict.txt
fairseq-preprocess \
    --only-source \
    --srcdict gpt2_bpe/dict.txt \
    --trainpref wikitext-103-raw/wiki.train.bpe \
    --validpref wikitext-103-raw/wiki.valid.bpe \
    --testpref wikitext-103-raw/wiki.test.bpe \
    --destdir data-bin/wikitext-103 \
    --workers 60
```
Run fairseq-train with SLURM srun
```bash
./fairseq_fsdp_interactive.sh
```
