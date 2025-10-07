#!/bin/bash
echo "🚀 FULL PROMOTION TO v1.1"
echo "100% traffic → v1.1 (Latest - Green)"
kubectl apply -f istio-config/latest-verion-update_only.yaml
echo "✅ Full promotion complete! All traffic now goes to latest v1.1"
./test-traffic-split.sh
