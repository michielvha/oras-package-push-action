#!/bin/bash
set -euo pipefail

# Package and push OCI artifact

ARTIFACT_NAME="${REGISTRY}/${REPOSITORY}"

echo "📦 Packaging OCI artifact: ${ARTIFACT_NAME}:${VERSION}"
echo "📂 Source path: ${SOURCE_PATH}"

# Change to working directory if specified
if [ -n "${WORKING_DIR}" ] && [ "${WORKING_DIR}" != "." ]; then
    cd "${WORKING_DIR}"
fi

# Expand glob pattern and check if files exist
shopt -s nullglob
FILES=(${SOURCE_PATH})
shopt -u nullglob

if [ ${#FILES[@]} -eq 0 ]; then
    echo "❌ Error: No files found matching pattern: ${SOURCE_PATH}"
    exit 1
fi

echo "Found ${#FILES[@]} file(s) to package:"
for file in "${FILES[@]}"; do
    echo "  - ${file}"
done

# Build OCI annotations
ANNOTATIONS=(
    "--annotation" "org.opencontainers.image.version=${VERSION}"
    "--annotation" "org.opencontainers.image.revision=${GITHUB_SHA}"
    "--annotation" "org.opencontainers.image.source=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
)

# Add description if provided
if [ -n "${DESCRIPTION}" ]; then
    ANNOTATIONS+=("--annotation" "org.opencontainers.image.description=${DESCRIPTION}")
fi

# Push artifact with primary version tag
echo "🚀 Pushing artifact with tag: ${VERSION}"
oras push "${ARTIFACT_NAME}:${VERSION}" \
    "${ANNOTATIONS[@]}" \
    "${FILES[@]}"

# Get digest from the push
DIGEST=$(oras discover "${ARTIFACT_NAME}:${VERSION}" --format json | jq -r '.manifests[0].digest // empty' || echo "")

# Apply additional tags
if [ -n "${ADDITIONAL_TAGS}" ]; then
    IFS=',' read -ra TAGS <<< "${ADDITIONAL_TAGS}"
    for tag in "${TAGS[@]}"; do
        tag=$(echo "${tag}" | xargs) # Trim whitespace
        if [ -n "${tag}" ]; then
            echo "🏷️  Tagging with: ${tag}"
            oras tag "${ARTIFACT_NAME}:${VERSION}" "${tag}"
        fi
    done
fi

# Build tags array for output
ALL_TAGS_JSON="[\"${VERSION}\""
if [ -n "${ADDITIONAL_TAGS}" ]; then
    IFS=',' read -ra TAGS <<< "${ADDITIONAL_TAGS}"
    for tag in "${TAGS[@]}"; do
        tag=$(echo "${tag}" | xargs)
        if [ -n "${tag}" ]; then
            ALL_TAGS_JSON="${ALL_TAGS_JSON},\"${tag}\""
        fi
    done
fi
ALL_TAGS_JSON="${ALL_TAGS_JSON}]"

# Set outputs
echo "artifact-url=${ARTIFACT_NAME}:${VERSION}" >> $GITHUB_OUTPUT
echo "digest=${DIGEST}" >> $GITHUB_OUTPUT
echo "all-tags=${ALL_TAGS_JSON}" >> $GITHUB_OUTPUT

echo "✅ Successfully pushed ${ARTIFACT_NAME}:${VERSION}"
echo "📊 Digest: ${DIGEST}"
