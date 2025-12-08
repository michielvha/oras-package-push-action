#!/bin/bash
set -euo pipefail

# Login to OCI registry

echo "🔐 Logging in to ${REGISTRY}..."

echo "${GITHUB_TOKEN}" | oras login "${REGISTRY}" -u "${GITHUB_ACTOR}" --password-stdin

echo "✅ Successfully authenticated to ${REGISTRY}"
