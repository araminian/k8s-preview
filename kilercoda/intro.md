# Welcome to Kubernetes Preview Environments! 🚀

In this hands-on tutorial, you'll learn how to create **cost-effective preview environments** on Kubernetes that:

- **Automatically deploy** for every Pull Request using GitOps
- **Scale to zero** when not in use to save resources
- **Provide dual URLs** for both human testing and automated verification
- **Auto-cleanup** when PRs are merged or closed

## What You'll Learn

By the end of this tutorial, you'll understand:

1. How to use **ArgoCD ApplicationSets** to dynamically create preview environments
2. How **KEDA HTTP Add-on** scales applications to zero and back
3. How **Istio** routes traffic to preview environments
4. Why you need **two URLs** (PR URL and Commit URL) for proper testing
5. How to integrate this into your CI/CD pipeline

## Prerequisites

This tutorial assumes you have:
- Basic knowledge of Kubernetes (Pods, Deployments, Services)
- Familiarity with Git and Pull Requests
- Understanding of basic YAML syntax

## The Big Picture

Preview environments allow developers to see their changes running in a real Kubernetes environment before merging. This tutorial is based on the KubeCon Amsterdam 2026 presentation.

Let's get started! 🎯
