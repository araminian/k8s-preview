# Quick Start: Publishing to Killercoda

This guide helps you quickly publish the Kubernetes Preview Environments tutorial to Killercoda.

## Option 1: GitHub Integration (Recommended)

1. **Ensure your repository is on GitHub**
   ```bash
   git add kilercoda/
   git commit -m "Add Killercoda tutorial"
   git push origin main
   ```

2. **Connect to Killercoda**
   - Go to https://killercoda.com/creators
   - Sign in with your GitHub account
   - Click "Create" → "New Scenario"
   - Select "Import from GitHub"
   - Choose your repository
   - Select the `kilercoda/` directory

3. **Test and Publish**
   - Killercoda will automatically validate the scenario
   - Click "Test" to try it out
   - When ready, click "Publish"

## Option 2: Manual Upload

1. **Prepare a ZIP file**
   ```bash
   cd kilercoda/
   zip -r ../killercoda-tutorial.zip *
   cd ..
   ```

2. **Upload to Killercoda**
   - Go to https://killercoda.com/creators
   - Click "Create" → "New Scenario"
   - Select "Upload ZIP"
   - Upload `killercoda-tutorial.zip`
   - Test and publish

## Option 3: Using Killercoda CLI

1. **Install the CLI**
   ```bash
   npm install -g @killercoda/cli
   ```

2. **Authenticate**
   ```bash
   killercoda login
   ```

3. **Validate the scenario**
   ```bash
   cd kilercoda/
   killercoda validate
   ```

4. **Create and upload**
   ```bash
   killercoda create --title "Kubernetes Preview Environments"
   # Note the scenario ID from the output
   
   killercoda upload --scenario-id <your-scenario-id>
   ```

## Verification Checklist

Before publishing, verify:

- [ ] All shell scripts are executable (`chmod +x *.sh`)
- [ ] `index.json` is valid JSON (use `jq . index.json`)
- [ ] All referenced files exist (steps, verify scripts)
- [ ] Background script clones the correct repository
- [ ] Step numbers are sequential (1-10)
- [ ] Verify scripts have proper exit codes

## Testing Tips

1. **Test verification scripts locally**
   ```bash
   # Each should exit with 0 on success
   ./verify-step2.sh
   echo $?  # Should print 0
   ```

2. **Check for typos**
   ```bash
   # Lint markdown files
   markdownlint *.md
   
   # Check shell scripts
   shellcheck *.sh
   ```

3. **Validate JSON**
   ```bash
   jq . index.json
   ```

## Customization for Your Environment

If you forked the repository, update these files:

1. **background.sh**
   ```bash
   # Line 18 - Change repository URL
   git clone https://github.com/YOUR-USERNAME/k8s-preview.git demo
   ```

2. **step10.md**
   ```yaml
   # Line with repoURL - Update to your fork
   repoURL: https://github.com/YOUR-USERNAME/k8s-preview.git
   ```

## Troubleshooting

### Scenario doesn't appear
- Check that `index.json` is valid JSON
- Ensure all referenced files exist
- Verify directory structure matches Killercoda requirements

### Steps don't verify correctly
- Test verify scripts in a real Kubernetes environment
- Check kubectl commands work with your cluster version
- Ensure proper error handling in verify scripts

### Background script fails
- Test the script in the Killercoda environment type
- Check network access requirements
- Verify all tools are available in the base image

## Support

- **Killercoda Documentation**: https://killercoda.com/creators/get-started
- **Tutorial Issues**: Open an issue in the main repository
- **Community**: Join the Killercoda Discord/Slack

## What's Next?

After publishing:

1. Share the tutorial link with your team
2. Gather feedback from users
3. Update based on common issues
4. Add more advanced scenarios
5. Create related tutorials (CI/CD integration, monitoring, etc.)

---

**Ready to publish?** Start with Option 1 (GitHub Integration) for the easiest experience!
