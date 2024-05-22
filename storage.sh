#!/bin/bash

# Parse cmd arguments
for i in "$@"; do
    case $i in
    -b=* | --bucket-name=*)
        BUCKET_NAME="${i#*=}"
        shift # past argument=value
        ;;
    -p=* | --project-id=*)
        PROJECT_ID="${i#*=}"
        shift # past argument=value
        ;;
    -* | --*)
        echo "Unknown option $i"
        exit 1
        ;;
    *) ;;
    esac
done

# Check if BUCKET_NAME is set & it's not empty
if [[ -z "${BUCKET_NAME}" ]]; then
    echo ">>> (Infra) | Critical: BUCKET_NAME environment variable is not set! Aborting..."
    exit 1
elif [[ -z "${PROJECT_ID}" ]]; then
    echo ">>> (Infra) | Critical: PROJECT_ID environment variable is not set! Aborting..."
    exit 1
fi

# Create bucket for the project
OUT=$(gcloud storage buckets create gs://$BUCKET_NAME --project=$PROJECT_ID --default-storage-class=STANDARD --location=EUROPE-WEST2 --uniform-bucket-level-access 2>&1 >/dev/null)

if [[ $OUT =~ "HTTPError 409" ]]; then
    echo ">>> (Infra) | <$BUCKET_NAME> bucket already exists in the <$PROJECT_ID> project. Skipping..."
elif [[ $OUT =~ "ERROR" ]]; then
    echo ">>> (Infra) | Fatal: unable to create <$BUCKET_NAME> bucket in the <$PROJECT_ID> project. Aborting..."
    exit 1
else
    echo ">>> (Infra) | Created <$BUCKET_NAME> bucket for in the <$PROJECT_ID> project."
fi
exit 0
