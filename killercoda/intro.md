# Welcome to Kubernetes Preview Environments! 🚀

In this hands-on tutorial, you'll learn how to create **cost-effective preview environments** on Kubernetes that:

- **Automatically deploy** for every Pull Request using GitOps
- **Scale to zero** when not in use to save resources
- **Provide dual URLs** for both human testing and automated verification
- **Auto-cleanup** when PRs are merged or closed

## What You'll Learn

By the end of this tutorial, you'll have hands-on experience with:

1. **Forking and configuring** a real GitHub repository for preview environments
2. **Setting up Docker Hub** integration for automated image builds
3. **Installing and configuring** ArgoCD, KEDA, and Istio on Kubernetes
4. **Creating ArgoCD ApplicationSets** that automatically deploy PRs
5. **Opening Pull Requests** and watching them auto-deploy
6. **Understanding KEDA HTTP Add-on** for cost-effective scaling to zero
7. **Implementing dual-URL strategy** for proper testing
8. **Integrating the complete workflow** into your CI/CD pipeline

You'll build a **complete, production-ready preview environment system** using your own GitHub and Docker Hub accounts!

## Prerequisites

This tutorial requires:

### Knowledge Prerequisites
- Basic knowledge of Kubernetes (Pods, Deployments, Services)
- Familiarity with Git and Pull Requests
- Understanding of basic YAML syntax
- Basic understanding of Docker containers

### Account Requirements

You'll need to create **free accounts** for:

1. **GitHub Account** (if you don't have one)
   - Sign up at: https://github.com/signup
   - Needed to: Fork the demo repository and open Pull Requests

2. **Docker Hub Account** (if you don't have one)
   - Sign up at: https://hub.docker.com/signup
   - Needed to: Store Docker images built by GitHub Actions

### What You'll Do

During this tutorial, you will:
- ✅ Fork a GitHub repository to your account
- ✅ Configure Docker Hub credentials as GitHub secrets
- ✅ Create a GitHub Personal Access Token for ArgoCD
- ✅ Make code changes and open Pull Requests
- ✅ Watch automated deployments happen in real-time

**Time commitment**: 60-90 minutes for the complete tutorial

**Note**: All accounts are free and don't require payment information.

## The Big Picture

Preview environments allow developers to see their changes running in a real Kubernetes environment before merging. This tutorial is based on the KubeCon Amsterdam 2026 presentation.

**Note**: In this interactive environment, services are exposed via NodePort and accessible through the tab navigation at the top right, or via the clickable links throughout the tutorial.

Let's get started! 🎯
