#!/bin/bash
echo "===================================================================="
echo "🔍 COMPLETE CANARY DEPLOYMENT VERIFICATION"
echo "===================================================================="

# Get basic info
EC2_IP=$(curl -s http://checkip.amazonaws.com)
NODE_PORT=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

echo ""
echo "📊 1. KUBERNETES CLUSTER STATUS"
echo "----------------------------------------"
echo "📦 Nodes:"
kubectl get nodes -o wide
echo ""

echo "🔧 2. PODS STATUS"
echo "----------------------------------------"
echo "📦 All Pods:"
kubectl get pods --all-namespaces -o wide
echo ""
echo "🎯 Canary App Pods:"
kubectl get pods -l app=canary-app -o wide
echo ""
echo "🔍 Pod Details:"
kubectl describe pods -l app=canary-app | grep -E "(Name:|Status:|Ready:|Image:)" | head -20

echo ""
echo "🌐 3. SERVICES STATUS"
echo "----------------------------------------"
echo "🔌 All Services:"
kubectl get svc --all-namespaces
echo ""
echo "🎯 Canary App Services:"
kubectl get svc -l app=canary-app

echo ""
echo "🚀 4. DEPLOYMENTS & REPLICAS"
echo "----------------------------------------"
echo "📈 Deployments:"
kubectl get deployments --all-namespaces
echo ""
echo "🎯 Canary Deployments:"
kubectl get deployments -l app=canary-app

echo ""
echo "🔗 5. ISTIO CONFIGURATION"
echo "----------------------------------------"
echo "🚪 Gateway:"
kubectl get gateway
echo ""
echo "🛣️  Virtual Services:"
kubectl get virtualservice
echo ""
echo "🏷️  Destination Rules:"
kubectl get destinationrule
echo ""
echo "📊 Current Traffic Split:"
kubectl get virtualservice canary-virtual-service -o jsonpath='{range .spec.http[0].route[*]}{.weight}% → {.destination.host}{"\n"}{end}'

echo ""
echo "🛠️ 6. ISTIO SYSTEM STATUS"
echo "----------------------------------------"
echo "🔧 Istio System Pods:"
kubectl get pods -n istio-system
echo ""
echo "🌐 Istio Services:"
kubectl get svc -n istio-system

echo ""
echo "📡 7. NETWORKING & ACCESS"
echo "----------------------------------------"
echo "🌍 Application URL:"
echo "   http://$EC2_IP:$NODE_PORT"
echo ""
echo "🔗 Ingress Gateway:"
kubectl get svc -n istio-system istio-ingressgateway -o wide

echo ""
echo "🧪 8. QUICK HEALTH CHECK"
echo "----------------------------------------"
echo "🔍 Pod Readiness:"
kubectl get pods -l app=canary-app -o jsonpath='{range .items[*]}{.metadata.name}: {.status.phase} {.status.containerStatuses[0].ready}{"\n"}{end}'
echo ""
echo "📈 Replica Status:"
kubectl get deployments -l app=canary-app -o jsonpath='{range .items[*]}{.metadata.name}: {.status.availableReplicas}/{.status.replicas} ready{"\n"}{end}'

echo ""
echo "🚦 9. TRAFFIC TEST (AUTOMATED)"
echo "----------------------------------------"
echo "Sending test traffic..."
v1_count=0
v2_count=0
for i in {1..5}; do
    response=$(curl -s http://$EC2_IP:$NODE_PORT 2>/dev/null || echo "ERROR")
    if echo "$response" | grep -q "Stable Version"; then
        ((v1_count++))
    elif echo "$response" | grep -q "Canary Version"; then
        ((v2_count++))
    fi
    sleep 1
done
echo "Quick test: $v1_count v1.0, $v2_count v1.1"

echo ""
echo "===================================================================="
echo "✅ VERIFICATION COMPLETE"
echo "===================================================================="
echo "Next steps:"
echo "1. Access application: http://$EC2_IP:$NODE_PORT"
echo "2. Run detailed test: ./test-traffic-split.sh"
echo "3. Check logs: kubectl logs -l app=canary-app --tail=10"
echo "===================================================================="
