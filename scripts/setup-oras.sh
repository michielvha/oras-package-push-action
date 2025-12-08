#!/bin/bash
set -euo pipefail

# Install ORAS CLI
VERSION="${ORAS_VERSION:-1.2.2}"

echo "📦 Installing ORAS CLI v${VERSION}..."

# Download and install
curl -LO "https://github.com/oras-project/oras/releases/download/v${VERSION}/oras_${VERSION}_linux_amd64.tar.gz"
mkdir -p oras-install/
tar -zxf oras_*.tar.gz -C oras-install/
sudo mv oras-install/oras /usr/local/bin/
rm -rf oras_*.tar.gz oras-install/

# Verify installation
oras version

echo "✅ ORAS CLI installed successfully"
