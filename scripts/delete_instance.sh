#!/usr/bin/env bash
# Usage: ./delete_instance.sh <INSTANCE_NAME> <ZONE>

INSTANCE_NAME=${1:-ml-spot-v100}
ZONE=${2:-us-central1-a}

echo "Deleting instance ${INSTANCE_NAME} in zone ${ZONE}..."
gcloud compute instances delete "${INSTANCE_NAME}" \
  --zone="${ZONE}" --quiet
