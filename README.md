# Kubernetes Canary Deployment with K3s and Istio

## Project Overview
Implement a modern canary deployment strategy with traffic splitting between stable and new application versions using K3s and Istio.

## Prerequisites
- AWS EC2 Account
- Docker Hub account (for container images)

## Step-by-Step Guide

### Step 1: Launch EC2 Instance
   - Name: `k3s-istio-canary`
   - AMI: Ubuntu 22.04 LTS
   - Instance Type: t3 medium 
   - Storage: 20GB SSD
   -  Security Group** (Allow these ports: 22, 80, 30000-32767)

### Step 2: Install Required Tools
