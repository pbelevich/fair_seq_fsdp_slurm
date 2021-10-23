# Run fairseq-train with SLURM srun/sbatch

Create conda env
```bash
conda create -yn fsdp_1T python=3.8
conda activate fsdp_1T
```
Install PyTorch (for EFA support see [the instuctions](efa_support.md))
```bash
conda install -y pytorch cudatoolkit=11.1 -c pytorch -c nvidia
```
Clone and install pbelevich/fairscale from source
```bash
git clone git@github.com:pbelevich/fairscale.git pbelevich-fairscale
cd pbelevich-fairscale
pip install -e .
cd ..
```
Clone and install pbelevich/fairseq from branch `fsdp_1T`
```bash
git clone -b fsdp_1T git@github.com:pbelevich/fairseq.git pbelevich-fairseq
cd pbelevich-fairseq
pip install -e .
cd ..
```
Install deepspeed
```bash
pip install deepspeed
```
Clone and build NVIDIA/apex
```bash
git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" \
  --global-option="--deprecated_fused_adam" --global-option="--xentropy" \
  --global-option="--fast_multihead_attn" ./
cd ..
```
[No need if you use fsdp_1T@pbelevich/fairseq] Quick fix [fairseq-deepspeed issue](https://github.com/pytorch/fairseq/issues/3810):
Open fairseq/optim/cpu_adam.py and add `, False` to [the line 116](https://github.com/pytorch/fairseq/blob/1f7ef9ed1e1061f8c7f88f8b94c7186834398690/fairseq/optim/cpu_adam.py#L116)

Clone this repo
```bash
git clone https://github.com/pbelevich/fsdp_1T.git
cd fsdp_1T
```

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
Run fairseq-train with SLURM sbatch (output to the file slurm-XXXXX.out)
```bash
sbatch fairseq_fsdp_sbatch.sh
```
To see the log:
```bash
tail -f -n +1 slurm-XXXXX.out
```
Run fairseq-train with SLURM srun (output to the screen)
```bash
./fairseq_fsdp_interactive.sh
```
