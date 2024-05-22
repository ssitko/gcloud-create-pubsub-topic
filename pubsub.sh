#!/bin/bash

# Parse cmd arguments
for i in "$@"; do
    case $i in
    -t=* | --topic-name=*)
        TOPIC_NAME="${i#*=}"
        TOPIC_SUBSCRIPTION="$TOPIC_NAME-sub"
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

# Check if TOPIC_NAME is set & it's not empty
if [[ -z "${TOPIC_NAME}" ]]; then
    echo ">>> (Infra) | Critical: TOPIC_NAME environment variable is not set! Aborting..."
    exit 1
elif [[ -z "${PROJECT_ID}" ]]; then
    echo ">>> (Infra) | Critical: PROJECT_ID environment variable is not set! Aborting..."
    exit 1
fi

# Create pubsub topic for the project
OUT=$(gcloud pubsub topics create --project=$PROJECT_ID --message-retention-duration=31d $TOPIC_NAME 2>&1 >/dev/null)

# Create topic if not exists
if [[ $OUT =~ "Created topic [projects/$PROJECT_ID/topics/$TOPIC_NAME" ]]; then
    echo ">>> (Infra) | Created <$TOPIC_NAME> topic in the <$PROJECT_ID> project."

    # Create subscription for the topic
    if gcloud pubsub subscriptions create $TOPIC_SUBSCRIPTION --topic $TOPIC_NAME; then
        echo ">>> (Infra) | Created <$TOPIC_SUBSCRIPTION> subscription for <$TOPIC_NAME> topic in the <$PROJECT_ID> project."
    else
        echo ">>> (Infra) | <$TOPIC_SUBSCRIPTION> subscription already exists for the <$TOPIC_NAME> topic. Skipping..."
    fi
elif [[ $OUT =~ "Resource already exists in the project (resource=$TOPIC_NAME)" ]]; then
    echo ">>> (Infra) | <$TOPIC_NAME> topic already exists in the project. Skipping..."
else
    echo ">>> (Infra) | Fatal: cannot create <$TOPIC_NAME> pubsub topic! Aborting..."
    echo $OUT
    exit 1
fi
exit 0
