# Killercoda Tutorial for Kubernetes Preview Environments

This directory contains a complete interactive tutorial for [Killercoda](https://killercoda.com/) that teaches how to build preview environments on Kubernetes.

## Tutorial Overview

**Title**: Kubernetes Preview Environments with GitOps
**Duration**: ~45-60 minutes
**Level**: Intermediate

### What Students Will Learn

- How to create cost-effective preview environments on Kubernetes
- Using ArgoCD ApplicationSets for dynamic environment creation
- Implementing auto-scaling to zero with KEDA HTTP Add-on
- Traffic routing with Istio Service Mesh
- The dual-URL strategy for proper testing
- Full GitOps workflow integration

## Tutorial Structure

The tutorial consists of 10 interactive steps:

1. **Understanding Preview Environments** - Introduction to concepts and challenges
2. **Setting Up the Kubernetes Cluster** - Exploring the demo application
3. **Installing ArgoCD** - Setting up the GitOps controller
4. **Installing KEDA and HTTP Add-on** - Enabling auto-scaling to zero
5. **Setting Up Istio** - Installing the service mesh
6. **Creating the Istio Gateway** - Configuring ingress routing
7. **Deploying a Preview Environment** - Hands-on deployment
8. **Testing Auto-Scaling to Zero** - Watching KEDA in action
9. **Understanding the Dual-URL Strategy** - Why two URLs are necessary
10. **Creating the ApplicationSet** - Automating everything with ArgoCD

## Files in This Directory

```
killercoda/
├── index.json              # Main configuration file
├── intro.md                # Welcome screen
├── finish.md               # Completion screen
├── background.sh           # Setup script (runs in background)
├── foreground.sh           # User-facing startup script
├── step1.md - step10.md    # Tutorial step content
└── verify-step*.sh         # Verification scripts for steps
```

## Publishing to Killercoda

### Prerequisites

1. Create a [Killercoda](https://killercoda.com/) account
2. Fork or use the Killercoda CLI to publish

### Option 1: Using Killercoda Creator

1. Log in to [Killercoda Creator](https://killercoda.com/creators)
2. Create a new scenario
3. Upload all files from this directory
4. Test the scenario
5. Publish when ready

### Option 2: Using Killercoda CLI

```bash
# Install the Killercoda CLI
npm install -g @killercoda/cli

# Navigate to this directory
cd kilercoda/

# Validate the scenario
killercoda validate

# Upload to Killercoda
killercoda upload --scenario-id <your-scenario-id>
```

### Option 3: GitHub Integration

1. Push this repository to GitHub
2. Connect your GitHub repository to Killercoda
3. Killercoda will automatically sync scenarios from the `kilercoda/` directory

## Customization

### Changing the Repository URL

If you've forked the main repository, update the repository URL in:
- `background.sh` (line with `git clone`)
- `step10.md` (ApplicationSet configuration)

### Adjusting Timing

- Modify `scaledownPeriod` in HTTPScaledObject examples for faster demos
- Adjust `requeueAfterSeconds` in ApplicationSet for quicker PR detection

### Adding More Content

You can add additional steps by:
1. Creating new `stepN.md` files
2. Adding corresponding `verify-stepN.sh` scripts
3. Updating `index.json` with the new steps

## Testing Locally

While Killercoda scenarios are designed to run on their platform, you can test the scripts locally:

```bash
# Make scripts executable
chmod +x *.sh

# Test individual steps
./background.sh
./verify-step2.sh
```

## Architecture Covered

The tutorial implements this architecture:

```
Developer → GitHub Actions → Docker Hub
                ↓
         Render Manifests → Temporary Branch
                ↓
   ArgoCD ApplicationSet → Deploy to K8s
                ↓
         KEDA HTTP Add-on → Scale to Zero
                ↓
              Istio → Route Traffic
                ↓
         Preview Environment Ready!
```

## Key Features

- **Interactive Commands**: Students execute real kubectl commands
- **Verification Scripts**: Automatic checks that steps completed correctly
- **Progressive Learning**: Each step builds on the previous
- **Hands-On Experience**: Deploy actual preview environments
- **Real-World Scenarios**: Based on production implementations

## Support

For questions about:
- **Tutorial content**: Open an issue in the main repository
- **Killercoda platform**: Visit [Killercoda Documentation](https://killercoda.com/creators/get-started)

## License

This tutorial is part of the KubeCon Amsterdam 2026 presentation materials and follows the same license as the main repository.

## Contributing

Improvements welcome! Please:
1. Test changes locally first
2. Ensure verification scripts work correctly
3. Keep step duration reasonable (5-7 minutes per step)
4. Maintain the conversational, friendly tone

---

**Note**: This tutorial is designed for Killercoda's Kubernetes environment. Some commands may need adjustment for other platforms.
