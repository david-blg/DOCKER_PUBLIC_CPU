#!/bin/bash

# REPO_ECR_NAME="<YOUR-REPOSITORY-ECR-NAME>"
# BLENDER_VERSIONS="cpu-3.6.0, gpu-3.6.0"
# AWS_ACCOUNT_ID="<YOUR-ACCOUNT-ID>"
# AWS_DEFAULT_REGION="<YOUR-REGION>"

REPO_ECR_NAME=$1
BLENDER_VERSIONS=$2
AWS_ACCOUNT_ID=$3
AWS_DEFAULT_REGION=$4

# Function to check if image exists in ECR
image_exists_in_manifest() {
    type=$1
    major_version=$2
    manifest_output=$(docker manifest inspect $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REPO_ECR_NAME:$type-$major_version 2>&1)
    if [[ $manifest_output == *"no such manifest:"* ]]; then
        echo "false"
    else
        echo "true"
    fi
}

# Function to build and push Docker images
build_and_push_image() {
    type=$1
    version=$2
    major_version=$3

    type=$(echo $type | tr '[:upper:]' '[:lower:]')
    echo "Type: $type, Version: $version, Major Version: $major_version"

    # Check if the Docker image already exists in ECR
    echo "Checking if Docker image $type exists in ECR"
    exists=$(image_exists_in_manifest  $type $major_version)
    if [[ $exists == "true" ]]; then
        echo "Docker image $type already exists in ECR"
        return
    fi

    echo "Building Docker image for $type, version $version, major version $major_version"

    cd docker/blender-$type

    docker build -t $REPO_ECR_NAME:$type-$major_version --build-arg BLENDER_VERSION=$version --build-arg BLENDER_VERSION_MAJOR=$major_version .
    # Login to ECR
    docker tag $REPO_ECR_NAME:$type-$major_version $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REPO_ECR_NAME:$type-$major_version
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$REPO_ECR_NAME:$type-$major_version

    echo "Docker image $type pushed to ECR for version $version"

    cd ../..
}
# Loop over Blender versions
IFS=',' read -ra VERSION_ARRAY <<<"$BLENDER_VERSIONS"
echo "Blender versions: $VERSION_ARRAY"
echo "ECR Repo Name: $REPO_ECR_NAME"
echo "AWS Account ID: $AWS_ACCOUNT_ID"
echo "AWS Default Region: $AWS_DEFAULT_REGION"

for version in "${VERSION_ARRAY[@]}"; do
    type=$(echo $version | cut -d'-' -f1)
    major_version=$(echo $version | cut -d'-' -f2)
    version_number="${major_version%.*}" # Extract the major version
    echo "Type: $type, Version: $version_number, Major Version: $major_version"
    exists_in_manifest=$(image_exists_in_manifest $type $version_number)
    if [[ $exists_in_manifest == "true" ]]; then
        echo "Docker image $type already exists in the manifest"
    else
        build_and_push_image $type $version_number $major_version
    fi
done

