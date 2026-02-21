#!/usr/bin/env bash
set -e

# =======================
# Color & Helper Function
# =======================
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

print_message() {
  echo -e "${1}${2}${RESET}"
}

# =======================
# Banner
# =======================
print_message "$BLUE"   "================================================="
print_message "$GREEN"  "🚀 Cloud9 Installation Script By king CeSembilan 🌟"
print_message "$BLUE"   "================================================="

# =======================
# Detect OS
# =======================
print_message "$YELLOW" "🔍 Detecting Linux distribution..."

if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS="$ID"
else
  print_message "$RED" "❌ Unable to detect Linux distribution. Exiting..."
  exit 1
fi

print_message "$BLUE" "🖥️ Detected OS: $OS"

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  print_message "$RED" "❌ Unsupported OS: $OS (Only Ubuntu & Debian supported)"
  exit 1
fi

# =======================
# Step 1: System Update
# =======================
print_message "$YELLOW" "⚙️ Step 1: Updating system..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y snapd git

print_message "$GREEN" "✅ System updated successfully."

# =======================
# Step 2: Docker Install
# =======================
print_message "$YELLOW" "🐳 Step 2: Installing Docker..."
sudo snap install docker
print_message "$GREEN" "✅ Docker installed successfully."

# =======================
# Step 3: Pull Cloud9 Image
# =======================
print_message "$YELLOW" "📥 Step 3: Pulling Cloud9 Docker image..."
sudo docker pull lscr.io/linuxserver/cloud9
print_message "$GREEN" "✅ Cloud9 image pulled."

# =======================
# Container Configuration
# =======================
USERNAME="king"
PASSWORD="king"
CONTAINER_NAME="King-CeSembilan"

# =======================
# Step 4: Run Container
# =======================
print_message "$YELLOW" "🚀 Step 4: Running Cloud9 container..."

sudo docker run -d \
  --name "$CONTAINER_NAME" \
  -e USERNAME="$USERNAME" \
  -e PASSWORD="$PASSWORD" \
  -p 8000:8000 \
  lscr.io/linuxserver/cloud9:latest

print_message "$GREEN" "✅ Cloud9 container running."

# =======================
# Step 5: Configure Cloud9
# =======================
print_message "$YELLOW" "⏳ Waiting 60 seconds for container startup..."
sleep 60

print_message "$YELLOW" "⚙️ Step 5: Configuring Cloud9..."

sudo docker exec "$CONTAINER_NAME" bash -c "
  apt update -y &&
  apt upgrade -y &&
  apt install -y wget curl php-cli php-curl &&
  curl -fsSL https://deb.nodesource.com/setup_16.x | bash - &&
  apt install -y nodejs &&
  node -v &&
  cd /c9bins/.c9 &&
  rm -f user.settings &&
  wget https://raw.githubusercontent.com/priv8-app/cloud9/refs/heads/main/user.settings
"

print_message "$GREEN" "✅ Cloud9 configured successfully."
print_message "$YELLOW" "🔍 Checking Node version..."
sudo docker exec "$CONTAINER_NAME" node -v
# =======================
# Restart Container
# =======================
print_message "$YELLOW" "♻️ Restarting Cloud9 container..."
sudo docker restart "$CONTAINER_NAME"
print_message "$GREEN" "✅ Container restarted."

# =======================
# Display Access Info
# =======================
print_message "$YELLOW" "🌐 Fetching public IP..."
PUBLIC_IP=$(curl -s ifconfig.me || echo "localhost")

print_message "$BLUE"   "==========================================="
print_message "$GREEN"  "🎉 Cloud9 by King Setup Completed Successfully 🎉"
print_message "$BLUE"   "==========================================="
print_message "$YELLOW" "🌟 Access: http://${PUBLIC_IP}:8000"
print_message "$YELLOW" "🔑 Username: $USERNAME"
print_message "$YELLOW" "🔑 Password: $PASSWORD"
print_message "$BLUE"   "==========================================="

# =======================
# Cleanup
# =======================
rm -f kingc9.sh c9.sh
