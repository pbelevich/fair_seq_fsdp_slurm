# AWS

The following commands must be executed in the Cloud Shell.

```bash
export CLUSTER_NAME=pbelevich-cluster-dl-fb
export REGION=us-east-1
```
## Create cluster:
```bash
pcluster create-cluster --cluster-configuration cluster-config.yaml --cluster-name ${CLUSTER_NAME} --region ${REGION}
```
## Update cluster:
```bash
pcluster update-compute-fleet --status STOP_REQUESTED --cluster-name ${CLUSTER_NAME}

pcluster update-cluster --cluster-name ${CLUSTER_NAME} --cluster-configuration cluster-config.yaml --region ${REGION}

pcluster update-compute-fleet --status START_REQUESTED --cluster-name ${CLUSTER_NAME}
```
## Delete cluster:
```bash
pcluster delete-cluster --cluster-name ${CLUSTER_NAME} --region us-east-1
```
## Export logs
```bash
pcluster export-cluster-logs --cluster-name ${CLUSTER_NAME} --region ${REGION} --bucket pbelevich-fb-com-logs --bucket-prefix logs
```
