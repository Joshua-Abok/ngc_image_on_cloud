#!/usr/bin/env bash
set -euo pipefail
# Usage: ./create_spot_instance.sh <INSTANCE_NAME> <ZONE> <PROJECT_ID> <STARTUP_SCRIPT_GCS_URL

INSTANCE_NAME="${1:-ml-gpu-vm}"
ZONE="${2:-us-central1-b}"
PROJECT="${3:-my-gcp-project}"
SERVICE_AC_NO="${4:-service-account-number}"
STARTUP_SCRIPT_URL="${5:-}"

echo "Creating GPU Spot VM: ${INSTANCE_NAME} in ${ZONE}..."

gcloud compute instances create "${INSTANCE_NAME}" \
  --project="${PROJECT}" \
  --zone="${ZONE}" \
  --machine-type=n1-standard-4 \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --no-restart-on-failure \
  --maintenance-policy=TERMINATE \
  --provisioning-model=SPOT \
  --instance-termination-action=STOP \
  --service-account=${SERVICE_AC_NO}-compute@developer.gserviceaccount.com \
  --scopes="https://www.googleapis.com/auth/devstorage.read_only,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/trace.append" \
  --accelerator=count=1,type=nvidia-tesla-v100 \
  --create-disk=auto-delete=yes,boot=yes,device-name="${INSTANCE_NAME}",\
image=projects/ml-images/global/images/c0-deeplearning-common-cpu-v20230925-debian-10,\
mode=rw,size=50,type=pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any \
  --metadata=startup-script-url=${STARTUP_SCRIPT_URL}
  # ${STARTUP_SCRIPT_URL:+--metadata=startup-script-url=${STARTUP_SCRIPT_URL}}
  

echo "✅ Instance '${INSTANCE_NAME}' created."

