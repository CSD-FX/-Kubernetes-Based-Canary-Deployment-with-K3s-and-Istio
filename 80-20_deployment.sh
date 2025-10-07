#!/bin/bash
echo "🎩 APPLYING 80/20 CANARY DEPLOYMENT"
echo "80% traffic → v1.0 (Stable - Blue)"
echo "20% traffic → v1.1 (Canary - Green)"
kubectl apply -f istio-config/80-20_deployment.yaml
echo "✅ 80/20 Canary deployment applied!"
./test-traffic-split.sh
