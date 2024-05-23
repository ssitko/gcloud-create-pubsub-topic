# #!/bin/bash

TOPIC_NAME=bleckmann-dead-letter-test-topic
PROJECT_ID=allsaints-cloud-dev

if [[ -z "${TOPIC_NAME}" ]]; then
    echo ">>> (Infra) | Critical: required <topic-bame> parameter is not set! Aborting..."
    exit 1
elif [[ -z "${PROJECT_ID}" ]]; then
    echo ">>> (Infra) | Critical: <project-id> parameter is not set! Aborting..."
    exit 1
fi

RESULT=$(
    gcloud pubsub topics list \
        --filter="name.scope(topics)=${TOPIC_NAME}" \
        --format="value(name)" 2>/dev/null
)

if [ "${RESULT}" == "" ]; then
    echo ">>> (Infra) | Topic ${TOPIC} does not exist, creating..."
    gcloud pubsub topics create --project=${PROJECT_ID} --message-retention-duration=31d $TOPIC_NAME
    if [ $? -eq 0 ]; then
        echo ">>> (Infra) | Successfully created $TOPIC_NAME topic in the $PROJECT_ID project"
        exit 0
    else
        echo ">>> (Infra) | Unable to create $TOPIC_NAME in the $PROJECT_ID project. Aborting..."
        exit 1
    fi
else
    echo ">>> (Infra) | Topic <$TOPIC_NAME> already exists in the <$PROJECT_ID> project. Skipping..."
fi
