# Configuring Docker Hub Access

For GitHub Actions to push Docker images, we need to configure Docker Hub credentials as GitHub Secrets.

## Create a Docker Hub Account

If you don't already have a Docker Hub account:

1. Go to [Docker Hub](https://hub.docker.com/signup)
2. Create a free account
3. Verify your email address

## Create a Docker Hub Access Token

For security, we'll use an access token instead of your password:

1. **Log in to Docker Hub**

2. **Click your username** (top-right) → **Account Settings**

3. **Click "Security"** in the left sidebar

4. **Click "New Access Token"**

5. **Configure the token**:
   - **Description**: `GitHub Actions - k8s-preview`
   - **Permissions**: **Read & Write**

6. **Click "Generate"**

7. **Copy the token** immediately (you won't see it again!)

## Add Secrets to Your GitHub Repository

Now add the Docker Hub credentials to your forked repository:

1. **Go to your fork** on GitHub:
   ```
   https://github.com/YOUR-USERNAME/k8s-preview
   ```

2. **Click "Settings"** (top menu)

3. **Click "Secrets and variables"** → **"Actions"** (left sidebar)

4. **Click "New repository secret"**

### Add DOCKERHUB_USERNAME

5. **Add the first secret**:
   - **Name**: `DOCKERHUB_USERNAME`
   - **Value**: Your Docker Hub username
   - **Click "Add secret"**

### Add DOCKERHUB_TOKEN

6. **Add the second secret**:
   - **Name**: `DOCKERHUB_TOKEN`
   - **Value**: The access token you copied earlier
   - **Click "Add secret"**

## Update skaffold.yaml with Your Docker Hub Username

The repository needs to know where to push Docker images.

### Option 1: Edit on GitHub

1. **Go to your fork** on GitHub

2. **Navigate to `skaffold.yaml`** in the root

3. **Click the edit button** (pencil icon)

4. **Find this section**:
   ```yaml
   build:
     artifacts:
       - image: araminian/todo-app  # Change this!
   ```

5. **Replace** `araminian` with **your Docker Hub username**:
   ```yaml
   build:
     artifacts:
       - image: YOUR-DOCKERHUB-USERNAME/todo-app
   ```

6. **Commit directly** to the main branch

### Option 2: Edit Locally (if you cloned)

```bash
# Edit skaffold.yaml
vi skaffold.yaml  # or use your preferred editor

# Change:
# - image: araminian/todo-app
# To:
# - image: YOUR-DOCKERHUB-USERNAME/todo-app

# Commit and push
git add skaffold.yaml
git commit -m "Update Docker Hub username"
git push origin main
```{{copy}}

## Verify Configuration

Let's make sure everything is configured correctly:

### Check GitHub Secrets

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. You should see:
   - ✅ `DOCKERHUB_USERNAME`
   - ✅ `DOCKERHUB_TOKEN`

### Check skaffold.yaml

1. Open `skaffold.yaml` in your fork
2. Verify the image name contains **your username**:
   ```yaml
   - image: YOUR-USERNAME/todo-app
   ```

## How GitHub Actions Uses These Secrets

When you open a Pull Request, the workflow (`.github/workflows/ci-preview.yaml`) will:

```yaml
- name: Log in to Docker Hub
  uses: docker/login-action@v2
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}

- name: Build and push Docker image
  run: |
    skaffold build --file-output=build.json
```

The workflow:
1. **Authenticates** with Docker Hub using your secrets
2. **Builds** the Docker image
3. **Tags** it with the PR number and commit SHA
4. **Pushes** it to your Docker Hub account

## Understanding the Image Tags

Images will be tagged as:
- `YOUR-USERNAME/todo-app:pr-123` (PR number)
- `YOUR-USERNAME/todo-app:pr-123-abc1234` (PR + commit SHA)

This allows:
- Multiple PRs to coexist
- Each commit to have its own image
- ArgoCD to deploy the exact version

## Quick Check

Make sure you have:

- [ ] Created a Docker Hub account
- [ ] Generated an access token
- [ ] Added `DOCKERHUB_USERNAME` secret to GitHub
- [ ] Added `DOCKERHUB_TOKEN` secret to GitHub
- [ ] Updated `skaffold.yaml` with your Docker Hub username
- [ ] Committed the changes to your fork

Perfect! Now we can create the ArgoCD ApplicationSet in the next step.
