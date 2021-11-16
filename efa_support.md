# EFA support

[The original AWS instuctions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start-nccl-base.html)

<details>
  <summary>Make sure that EFA software components are installed</summary>

Run the following on p4d.24xlarge worker(not jump host):

```bash
fi_info -p efa -t FI_EP_RDM
```

It should print something like this:

```
provider: efa
    fabric: EFA-fe80::10d8:baff:fec9:6c1
    domain: rdmap16s27-rdm
    version: 111.20
    type: FI_EP_RDM
    protocol: FI_PROTO_EFA
provider: efa
    fabric: EFA-fe80::1011:66ff:feeb:c5af
    domain: rdmap32s27-rdm
    version: 111.20
    type: FI_EP_RDM
    protocol: FI_PROTO_EFA
provider: efa
    fabric: EFA-fe80::102f:29ff:fe3d:1685
    domain: rdmap144s27-rdm
    version: 111.20
    type: FI_EP_RDM
    protocol: FI_PROTO_EFA
provider: efa
    fabric: EFA-fe80::1059:7cff:fe95:ed6d
    domain: rdmap160s27-rdm
    version: 111.20
    type: FI_EP_RDM
    protocol: FI_PROTO_EFA
```
  
If it prints something like
```
fi_getinfo: -61
```

then try to install according to [the instructios](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start-nccl-base.html#nccl-start-base-enable) (if you have `sudo` privileges)
  
Another test for EFA support
```bash
/opt/amazon/efa/test/efa_test.sh
Starting server...
Starting client...
bytes   #sent   #ack     total       time     MB/sec    usec/xfer   Mxfers/sec
64      10      =10      1.2k        0.03s      0.04    1579.10       0.00
256     10      =10      5k          0.00s     10.92      23.45       0.04
1k      10      =10      20k         0.00s     42.40      24.15       0.04
4k      10      =10      80k         0.00s    169.26      24.20       0.04
64k     10      =10      1.2m        0.00s    722.16      90.75       0.01
1m      10      =10      20m         0.01s   2614.25     401.10       0.00
```
  
</details>

## For EFA support you need to build PyTorch from source

<details>
  <summary>Build PyTorch from source</summary>
  
Create conda env
```bash
conda create -yn fsdp_1T_efa python=3.8
conda activate fsdp_1T_efa
conda install -y astunparse numpy ninja pyyaml mkl mkl-include setuptools cmake cffi typing_extensions future six requests dataclasses
conda install -y -c pytorch magma-cuda110
```
Checkout and build PyTorch from source(TORCH_CUDA_ARCH_LIST=8.0 for p4d.24xlarge's A100)
```bash
git clone --recursive git@github.com:pytorch/pytorch.git
cd pytorch
# git checkout v1.10.0
TORCH_CUDA_ARCH_LIST=8.0 python setup.py install
```
</details>

(also you need to build corresponding torchaudio version if you want to run fairseq)

<details>
  <summary>Build torchaudio from source</summary>

```bash
git clone --recursive git@github.com:pytorch/audio.git
cd audio
git checkout v0.10.0
python setup.py install
```
</details>

## Install the aws-ofi-nccl plugin
Assuming that you don't have access to `/opt` let's use your home directory for aws-ofi-nccl installation. 
```bash
export WORK_DIR=${HOME} # I use /fsx/users/pbelevich
```

```bash
git clone -b aws https://github.com/aws/aws-ofi-nccl.git ${WORK_DIR}/aws-ofi-nccl-src

cd ${WORK_DIR}/aws-ofi-nccl-src

./autogen.sh

./configure --prefix=${WORK_DIR}/aws-ofi-nccl \
--with-libfabric=/opt/amazon/efa \
--with-nccl=${WORK_DIR}/pytorch/build/nccl \
--with-cuda=$CUDA_HOME

make

make install
```

## To run PyTorch distributed using NCCL with EFA support you need to set the following environment variables:
```
export LD_LIBRARY_PATH=/opt/amazon/efa/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${WORK_DIR}/aws-ofi-nccl/lib:$LD_LIBRARY_PATH
export NCCL_DEBUG=INFO
export FI_PROVIDER="efa"
export FI_EFA_USE_DEVICE_RDMA=1
export NCCL_ALGO=ring
```

If everything works correctly then you should expect to see the following lines in the log
```
NCCL INFO NET/OFI Selected Provider is efa
NCCL INFO NET/OFI Running on P4d platform, Setting NCCL_TOPO_FILE environment variable to .../aws-ofi-nccl/share/aws-ofi-nccl/xml/p4d-24xl-topo.xml
```

PS: FSDP works faster with `ENABLE_NCCL_BASE_COLLECTIVES=0`

