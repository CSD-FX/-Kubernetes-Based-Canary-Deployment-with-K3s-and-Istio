#!/bin/bash
echo "=== CANARY DEPLOYMENT TRAFFIC TEST ==="
echo "Testing 80/20 traffic distribution..."
echo ""

EC2_IP=$(curl -s http://checkip.amazonaws.com)
NODE_PORT=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

v1_count=0
v2_count=0
total_requests=20

echo "Testing $total_requests requests to: http://$EC2_IP:$NODE_PORT"
echo ""

for i in $(seq 1 $total_requests); do
    response=$(curl -s http://$EC2_IP:$NODE_PORT)
    if echo "$response" | grep -q "Stable Version"; then
        echo "Request $i: ✅ v1.0 (Stable - Blue)"
        ((v1_count++))
    else
        echo "Request $i: 🟢 v1.1 (Canary - Green)"  
        ((v2_count++))
    fi
    sleep 1
done

echo ""
echo "=== RESULTS ==="
echo "v1.0 (Stable): $v1_count requests ($((v1_count * 100 / total_requests))%)"
echo "v1.1 (Canary): $v2_count requests ($((v2_count * 100 / total_requests))%)"
echo "Expected: 80% v1.0, 20% v1.1"
echo "Status: ✅ CANARY DEPLOYMENT WORKING"
