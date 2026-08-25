#!/bin/bash

set -u

health_check() {
    for attempt in {1..12}; do
        echo "Health check attempt $attempt/12"

        if curl --fail --silent --show-error http://127.0.0.1/health; then
            echo
            return 0
        fi

        sleep 5
    done

    return 1
}

NEW_IMAGE="$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

echo "Logging into ECR"

aws ecr get-login-password --region "$AWS_REGION" \
    | docker login \
        --username AWS \
        --password-stdin "$ECR_REGISTRY"

echo "Deploying $NEW_IMAGE"

PREVIOUS_IMAGE=$(docker inspect symfony-app \
    --format='{{.Config.Image}}' 2>/dev/null || true)

echo "Previous image: ${PREVIOUS_IMAGE:-none}"

docker pull "$NEW_IMAGE" || exit 1

docker rm -f symfony-app || true

docker run -d \
    --restart unless-stopped \
    --name symfony-app \
    -p 80:8000 \
    "$NEW_IMAGE"

if health_check; then
    echo "Deployment successful"
    exit 0
fi

echo "Health check failed"

docker rm -f symfony-app || true

if [ -n "$PREVIOUS_IMAGE" ]; then
    echo "Rolling back to $PREVIOUS_IMAGE"

    docker run -d \
        --restart unless-stopped \
        --name symfony-app \
        -p 80:8000 \
        "$PREVIOUS_IMAGE"

    if health_check; then
        echo "Rollback successful"
    else
        echo "CRITICAL: Rollback health check failed"
    fi
else
    echo "No previous image available for rollback"
fi

exit 1