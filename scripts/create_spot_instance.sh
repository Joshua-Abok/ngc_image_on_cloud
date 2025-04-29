#!/usr/bin/env bash 
# Usage: ./create_spot_instance.sh <INSTANCE_NAME> <ZONE> <PROJECT_ID> <STARTUP_SCRIPT_GCS_URL>

INSTANCE_NAME=${1:-ml-spot-v100}
ZONE=${2:-us-central1-a}
PROJECT_ID=${3:-my-gcp-project}
STARTUP_SCRIPT=${4:-"gs://my-bucket/startup-script.sh"}

echo "Creating preemptiple VM '${INSTANCE_NAME}' in ${ZONE}..."

gcloud compute instances create "${INSTANCE_NAME}" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \ 
    --machine-type=n1-standard-8 \
    --accelerator="type=nvidia-tesla-v100, count=1" \ 
    --image-family=ubuntu-20-04 \ 
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=100GB \
    --maintenance-policy=TERMINATE \ 
    --preemptiple \ 
    --metadata=install-nvidia-driver=True, startup-script-url="${STARTUP_SCRIPT}" \
    --scopes=https://www.googleapis.com/auth/cloud-platform

echo "Instance '${INSTANCE_NAME}' created. It will run the startup script on boot."