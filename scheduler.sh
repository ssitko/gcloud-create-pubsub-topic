#!/bin/bash

# Parse cmd arguments
for i in "$@"; do
    case $i in
    -p=* | --project-id=*)
        PROJECT_ID="${i#*=}"
        shift # past argument=value
        ;;
    -n=* | --scheduler-name=*)
        SCHEDULER_JOB_NAME="${i#*=}"
        shift # past argument=value
        ;;
    -s=* | --schedule=*)
        SCHEDULE="${i#*=}"
        shift # past argument=value
        ;;
    -n=* | --topic-name=*)
        TOPIC_NAME="${i#*=}"
        shift # past argument=value
        ;;
    -t=* | --subscription-type=*)
        SUBSCRIPTION_TYPE="${i#*=}"
        shift # past argument=value
        ;;
    -b=* | --message-body=*)
        MESSAGE_BODY="${i#*=}"
        shift # past argument=value
        ;;
    -* | --*)
        echo "Unknown option $i"
        exit 1
        ;;
    *) ;;
    esac
done

# Check if all required parameters are set & not empty
if [[ -z "${SCHEDULER_JOB_NAME}" ]]; then
    echo ">>> (Infra) | Critical: SCHEDULER_JOB_NAME parameter is not set! Aborting..."
    exit 1
elif [[ -z "${SCHEDULE}" ]]; then
    echo ">>> (Infra) | Critical: SCHEDULE parameter is not set! Aborting..."
    exit 1
elif [[ -z "${TOPIC_NAME}" ]]; then
    echo ">>> (Infra) | Critical: TOPIC_NAME parameter is not set! Aborting..."
    exit 1
elif [[ -z "${MESSAGE_BODY}" ]]; then
    echo ">>> (Infra) | Critical: MESSAGE_BODY parameter is not set! Aborting..."
    exit 1
elif [[ -z "${PROJECT_ID}" ]]; then
    echo ">>> (Infra) | Critical: PROJECT_ID parameter is not set! Aborting..."
    exit 1
elif [[ -z "${SUBSCRIPTION_TYPE}" ]]; then
    echo ">>> (Infra) | Critical: SUBSCRIPTION_TYPE parameter is not set! Aborting..."
    exit 1
fi

# Create job scheduler for subscription
OUT=$(gcloud scheduler jobs create $SUBSCRIPTION_TYPE $SCHEDULER_JOB_NAME --schedule="$SCHEDULE" --topic=$TOPIC_NAME --message-body=$MESSAGE_BODY 2>&1 >/dev/null)

# Assess scheduler create results
if [[ $OUT =~ "ALREADY_EXISTS: Job projects/$PROJECT_ID/locations/europe-west2/jobs/$SCHEDULER_JOB_NAME already exists." ]]; then
    echo ">>> (Infra) | $SCHEDULER_JOB_NAME scheduler already exists in the $PROJECT_ID project. Aborting..."
else
    if gcloud scheduler jobs describe $SCHEDULER_JOB_NAME; then
        echo ">>> (Infra) | Created $SCHEDULER_JOB_NAME scheduler in the $PROJECT_ID project with $TOPIC_NAME subscription."
    else
        echo ">>> (Infra) | Fatal exception when attempting to create $SCHEDULER_JOB_NAME scheduler. Aborting..."
        echo $OUT
        exit 1
    fi
fi
