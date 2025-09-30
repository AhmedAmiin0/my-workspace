# Deployment Setup

This repository is configured to automatically deploy to `/var/project` on your server after GitHub Actions completes successfully.

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository settings:

1. **HOST**: Your server's IP address (e.g., `148.230.116.195`)
2. **USERNAME**: SSH username (e.g., `root`)
3. **SSH_KEY**: Your private SSH key for authentication
4. **SSH_PASSPHRASE**: The passphrase for your SSH key (if your key has one)

## How to Set Up Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. In the left sidebar, click "Secrets and variables" → "Actions"
4. Click "New repository secret" and add each secret:
   - Name: `HOST`, Value: `148.230.116.195`
   - Name: `USERNAME`, Value: `root`
   - Name: `SSH_KEY`, Value: `[your private SSH key content]`
   - Name: `SSH_PASSPHRASE`, Value: `[your SSH key passphrase]`

## SSH Key Setup

### Generate SSH Key (if you don't have one):
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### Copy Public Key to Server:
```bash
ssh-copy-id root@148.230.116.195
```

### Get Private Key for GitHub Secret:
```bash
cat ~/.ssh/id_rsa
```
Copy the entire output (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`) and paste it as the `SSH_KEY` secret value.

## Troubleshooting SSH Connection

If you get "can't connect without a private SSH key or password" error:

1. **Verify SSH Key Format**: The private key should include the header and footer lines
2. **Test SSH Connection Locally**:
   ```bash
   ssh root@148.230.116.195
   ```
3. **Check Server SSH Configuration**: Ensure SSH is enabled and accepting key authentication
4. **Verify GitHub Secrets**: Double-check that all three secrets are set correctly

## Deployment Process

The workflow will:

1. **Build**: Install dependencies and build the customer-app
2. **Transfer**: Copy built files and deployment script to your server
3. **Deploy**: Run the deployment script on your server to:
   - Create backup of current deployment
   - Deploy new version to `/var/project`
   - Set proper permissions
   - Clean up temporary files

## Server Requirements

Your server should have:
- SSH access enabled
- Write permissions to `/var/project`
- Node.js installed (if your app requires it)
- Any web server (nginx, apache) configured to serve from `/var/project`

## Manual Deployment

If you need to deploy manually:

```bash
# Build the project locally
pnpm install
npx nx build customer-app

# Copy files to server
scp -r dist/apps/customer-app/* root@148.230.116.195:/var/project/
```

## Troubleshooting

- Check GitHub Actions logs for deployment errors
- Verify SSH key has proper permissions on the server
- Ensure `/var/project` directory exists and is writable
- Check server logs for application-specific issues
