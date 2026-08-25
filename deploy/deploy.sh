#!/bin/bash

set -u

NEW_IMAGE="$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

echo "Logging into ECR"

echo "Deploying $NEW_IMAGE"

aws ecr get-login-password --region "$AWS_REGION" \
    | docker login \
        --username AWS \
        --password-stdin "$ECR_REGISTRY"

# Remember what's currently running
PREVIOUS_IMAGE=$(docker inspect symfony-app \
    --format='{{.Config.Image}}' 2>/dev/null || true)

echo "Previous image: ${PREVIOUS_IMAGE:-none}"

# Pull first — don't touch production if the image can't even be pulled
docker pull "$NEW_IMAGE" || exit 1

# Replace current container
docker rm -f symfony-app || true

docker run -d \
    --restart unless-stopped \
    --name symfony-app \
    -p 80:8000 \
    "$NEW_IMAGE"

# Verify new version
if curl --fail --silent --show-error \
    --retry 12 \
    --retry-delay 5 \
    --retry-connrefused \
    --retry-max-time 60 \
    http://localhost/health
then
    echo "Deployment successful"
    exit 0
fi

echo "Health check failed"

# Remove broken version
docker rm -f symfony-app || true

# Roll back
if [ -n "$PREVIOUS_IMAGE" ]; then
    echo "Rolling back to $PREVIOUS_IMAGE"

    docker run -d \
        --restart unless-stopped \
        --name symfony-app \
        -p 80:8000 \
        "$PREVIOUS_IMAGE"

    # Verify rollback itself worked
    if curl --fail --silent --show-error \
        --retry 12 \
        --retry-delay 5 \
        --retry-connrefused \
        --retry-max-time 60 \
        http://localhost/health
    then
        echo "Rollback successful"
    else
        echo "CRITICAL: Rollback health check failed"
    fi
else
    echo "No previous image available for rollback"
fi

# The deployment was bad even if rollback succeeded.
exit 1