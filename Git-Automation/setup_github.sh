#!/bin/bash

set -e  # Exit on any error

USERNAME=$1
GITHUB_REPO=$2
GIT_USER_NAME=$3
GIT_USER_EMAIL=$4
GITHUB_API_TOKEN=$5
USER_HOME="/home/$USERNAME"

if [ -z "$USERNAME" ] || [ -z "$GITHUB_REPO" ] || [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ] || [ -z "$GITHUB_API_TOKEN" ]; then
    echo "❌ Error: Missing parameters."
    echo "Usage: bash setup_github.sh <username> <github_repo_url> <git_user_name> <git_user_email> <github_api_token>"
    exit 1
fi

# Setup SSH authentication
sudo -u $USERNAME mkdir -p $USER_HOME/.ssh
sudo -u $USERNAME chmod 700 $USER_HOME/.ssh

if [ ! -f "$USER_HOME/.ssh/id_rsa" ]; then
    echo "🔹 Generating SSH key..."
    sudo -u $USERNAME ssh-keygen -t rsa -b 4096 -C "$USERNAME@$(hostname)" -f $USER_HOME/.ssh/id_rsa -N ""
    echo "✅ SSH key generated."
else
    echo "✅ SSH key already exists."
fi

# Secure SSH Key Permissions
echo "Host github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no" | sudo -u $USERNAME tee $USER_HOME/.ssh/config > /dev/null
sudo -u $USERNAME chmod 600 $USER_HOME/.ssh/config
sudo -u $USERNAME chmod 600 $USER_HOME/.ssh/id_rsa
sudo -u $USERNAME chmod 644 $USER_HOME/.ssh/id_rsa.pub

# Auto-add SSH key to GitHub
SSH_KEY_CONTENT=$(sudo -u $USERNAME cat $USER_HOME/.ssh/id_rsa.pub)
curl -H "Authorization: token $GITHUB_API_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     --data "{\"title\":\"$USERNAME@$(hostname)\", \"key\":\"$SSH_KEY_CONTENT\"}" \
     https://api.github.com/user/keys

echo "🔹 Configuring Git for $USERNAME..."
sudo -u $USERNAME git config --global user.name "$GIT_USER_NAME"
sudo -u $USERNAME git config --global user.email "$GIT_USER_EMAIL"

echo "🔹 Testing GitHub SSH connection..."
sudo -u $USERNAME ssh -o StrictHostKeyChecking=no git@github.com || true

# Clone the GitHub repository
if [ -d "$USER_HOME/github/.git" ]; then
    echo "✅ Repository already exists. Pulling latest updates..."
    sudo -u $USERNAME git -C $USER_HOME/github pull origin main
else
    echo "🔹 Cloning GitHub repository..."
    sudo -u $USERNAME git clone "$GITHUB_REPO" "$USER_HOME/github"
fi
# Create GitHub repository structure
sudo -u $USERNAME mkdir -p $USER_HOME/github/dev/src
sudo -u $USERNAME mkdir -p $USER_HOME/github/stage/src
sudo -u $USERNAME mkdir -p $USER_HOME/github/prod/src
echo "✅ GitHub setup complete!"
