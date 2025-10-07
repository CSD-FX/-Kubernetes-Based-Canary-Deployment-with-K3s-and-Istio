#!/bin/bash
echo "🚨 EMERGENCY ROLLBACK TO v1.0"
echo "100% traffic → v1.0 (Stable - Blue)"
kubectl apply -f istio-config/previous-version-rollback.yaml
echo "✅ Rollback complete! All traffic now goes to stable v1.0"
./test-traffic-split.sh
