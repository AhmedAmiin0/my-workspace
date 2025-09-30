# SSH Connection Troubleshooting Guide

## Current Error Analysis
The error `ssh: no key found` and `ssh: handshake failed: ssh: unable to authenticate, attempted methods [none]` indicates:

1. **SSH_KEY secret is empty or malformed**
2. **SSH key format is incorrect**
3. **Public key not properly added to server**

## Step-by-Step Fix

### 1. Generate SSH Key (if needed)
```bash
# Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -C "github-actions@your-domain.com"

# When prompted, press Enter to use default location (~/.ssh/id_rsa)
# Optionally set a passphrase (recommended for security)
```

### 2. Copy Public Key to Server
```bash
# Method 1: Using ssh-copy-id (recommended)
ssh-copy-id root@148.230.116.195

# Method 2: Manual copy
cat ~/.ssh/id_rsa.pub | ssh root@148.230.116.195 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"
```

### 3. Test SSH Connection Locally
```bash
# Test the connection
ssh root@148.230.116.195

# If successful, you should see the server prompt
# Exit with: exit
```

### 4. Get Private Key for GitHub Secret
```bash
# Display the private key (copy the ENTIRE output)
cat ~/.ssh/id_rsa
```

**Important**: Copy the ENTIRE output including:
- `-----BEGIN OPENSSH PRIVATE KEY-----`
- The key content (multiple lines)
- `-----END OPENSSH PRIVATE KEY-----`

### 5. Set GitHub Secrets

Go to your GitHub repository:
1. Settings → Secrets and variables → Actions
2. Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `HOST` | `148.230.116.195` |
| `USERNAME` | `root` |
| `SSH_KEY` | `[paste the entire private key from step 4]` |

### 6. Test with Manual Workflow

I've created a test workflow (`.github/workflows/test-ssh.yml`) that you can run manually:
1. Go to Actions tab in your GitHub repository
2. Click "Test SSH Connection" workflow
3. Click "Run workflow" button
4. Check the logs for connection details

## Common Issues and Solutions

### Issue: "ssh: no key found"
**Solution**: SSH_KEY secret is empty or malformed
- Re-copy the private key exactly as shown in step 4
- Ensure no extra spaces or characters

### Issue: "ssh: handshake failed"
**Solution**: Public key not on server or wrong format
- Re-run step 2 to copy public key to server
- Check server's `~/.ssh/authorized_keys` file

### Issue: "Permission denied (publickey)"
**Solution**: Server SSH configuration
- Check `/etc/ssh/sshd_config` on server
- Ensure `PubkeyAuthentication yes`
- Restart SSH service: `systemctl restart sshd`

### Issue: Connection timeout
**Solution**: Network/firewall issues
- Check if server is accessible: `ping 148.230.116.195`
- Verify SSH port 22 is open
- Check server firewall settings

## Server-Side Verification

SSH into your server and check:

```bash
# Check if authorized_keys exists and has content
ls -la ~/.ssh/
cat ~/.ssh/authorized_keys

# Check SSH service status
systemctl status sshd

# Check SSH configuration
grep -E "PubkeyAuthentication|AuthorizedKeysFile" /etc/ssh/sshd_config
```

## Alternative: Use Password Authentication (Not Recommended)

If SSH keys continue to fail, you can temporarily use password authentication:

1. Add `PASSWORD` secret to GitHub
2. Update workflow to use password instead of key
3. **Security Warning**: This is less secure than key-based authentication

```yaml
- name: Deploy to server
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    password: ${{ secrets.PASSWORD }}
    script: |
      echo "Deployment script here"
```

## Next Steps

1. Follow steps 1-6 above
2. Run the test workflow to verify connection
3. If successful, the main deployment workflow should work
4. If still failing, check the server logs: `journalctl -u sshd -f`
