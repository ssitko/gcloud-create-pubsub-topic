# gcloud pubsub create topic

This repository contains Github action for creating google _pubsub_ topics & topic subscriptions, using **gcloud** utility.

# how to use

1. Make sure that **google-github-actions/auth** and **google-github-actions/setup-gcloud** actions are running before this github action in your manifest
2. Add following lines to you github action:

your-gh-manifest.yaml

```
- name: Use gcloud pubsub create topic action
  uses: ssitko/gcloud-create-pubsub-topic@0.1
  with:
    project-id: your-project-id
    topic-name: your-topic-name
    subscription-name: optional-subscription-name // this is optional
```

### Szymon Sitko @ 2024
