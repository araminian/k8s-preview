# Forking the Repository and Setup

Now that our Kubernetes infrastructure is ready, let's set up your own GitHub repository to create real preview environments with Pull Requests!

## Why Fork the Repository?

To create preview environments from Pull Requests, you need:
- Your own GitHub repository to open PRs against
- GitHub Actions that build and push Docker images
- Ability to configure secrets for Docker Hub access

## Fork the Repository

1. **Open the repository** in a new browser tab:

[Fork the Demo Repository](https://github.com/araminian/k8s-preview)

2. **Click the "Fork" button** in the top-right corner

3. **Select your GitHub account** as the destination

4. **IMPORTANT: Keep the repository public** (this is the default)
   - ArgoCD will read from your public repository without authentication
   - If you make it private, you'll need to configure additional credentials

5. **Wait for the fork to complete**

You now have your own copy at: `https://github.com/YOUR-USERNAME/k8s-preview`

## Clone Your Fork Locally (Optional)

If you want to make changes locally and push them:

```bash
# Replace YOUR-USERNAME with your GitHub username
git clone https://github.com/YOUR-USERNAME/k8s-preview.git
cd k8s-preview
```{{copy}}

**Note**: For this tutorial, you can also make changes directly in the GitHub web interface.

## Understanding the Repository Structure

Let's explore what's in the repository:

### Application Code
```
src/                    # React TODO application
├── components/         # UI components
├── App.jsx            # Main application
└── ...
```

### Kubernetes Configuration
```
kubernetes/
├── charts/todo-app/   # Helm chart for the application
├── argocd/           # ArgoCD ApplicationSet
└── istio/            # Istio Gateway
```

### GitHub Actions Workflow
```
.github/workflows/
└── ci-preview.yaml    # Builds image and renders manifests
```

## How the Workflow Works

When you open a Pull Request:

1. **GitHub Action triggers** (`.github/workflows/ci-preview.yaml`)
2. **Builds Docker image** with PR number as tag
3. **Pushes image to Docker Hub**
4. **Renders Kubernetes manifests** using Skaffold
5. **Pushes manifests** to a temporary branch (`preview-{PR_NUMBER}`)
6. **Adds `preview` label** to the PR
7. **ArgoCD ApplicationSet detects** the new PR
8. **Deploys preview environment** automatically!

## The TODO Application

The demo application is a simple TODO list built with:
- **Frontend**: React + Vite
- **Styling**: CSS
- **No backend**: Uses local storage

It's perfect for demonstrating preview environments because:
- Quick to build (~30 seconds)
- Small Docker image size
- Easy to see changes visually
- No database dependencies

## What You'll Need Next

Before we can create preview environments, you need to:

1. ✅ **Fork the repository** (you just did this!)
2. ⏭️ **Configure Docker Hub** (next step)
3. ⏭️ **Create ApplicationSet** in ArgoCD
4. ⏭️ **Open a Pull Request**
5. ⏭️ **Watch ArgoCD deploy it!**

## Quick Check

Make sure you have:

- [ ] Forked the repository to your GitHub account
- [ ] Noted your fork URL: `https://github.com/YOUR-USERNAME/k8s-preview`
- [ ] (Optional) Cloned it locally if you prefer

Ready? Let's configure Docker Hub access in the next step!
