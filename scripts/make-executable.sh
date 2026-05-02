#!/bin/bash
# Make all scripts executable

chmod +x scripts/deploy-local.sh
chmod +x scripts/deploy-k8s.sh
chmod +x scripts/deploy-complete.sh
chmod +x scripts/setup-aws-ec2.sh
chmod +x scripts/cleanup-k8s.sh
chmod +x scripts/update-image-tags.sh

echo "✅ All scripts are now executable"
ls -la scripts/
