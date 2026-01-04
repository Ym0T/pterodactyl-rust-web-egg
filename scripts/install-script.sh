#!/bin/bash
# Rust Web Egg Installation Script
apt update
apt install -y curl git wget

cd /mnt/server

# Add VERSION file
wget -q -O - https://api.tavuru.de/version/Ym0T/pterodactyl-rust-web-egg | grep -o '"version":"[^"]*"' | cut -d'"' -f4 | head -1 > /mnt/server/VERSION

# Clone the default repository into a temporary directory
echo "[Git] Cloning default repository"
git clone https://github.com/Ym0T/pterodactyl-rust-web-egg /mnt/server/gtemp > /dev/null 2>&1

# Copy necessary files
cp -r /mnt/server/gtemp/modules /mnt/server
cp -r /mnt/server/gtemp/scripts /mnt/server
cp /mnt/server/gtemp/start-modules.sh /mnt/server
cp /mnt/server/gtemp/LICENSE /mnt/server
chmod +x /mnt/server/start-modules.sh
find /mnt/server/modules -type f -name "*.sh" -exec chmod +x {} \;

# Remove temp directory
rm -rf /mnt/server/gtemp

# Create necessary directories
mkdir -p logs tmp data bin

# Clone user repository if GIT_REPO is set
if [ ! -z "${GIT_REPO}" ]; then
    echo "[Git] Cloning user repository: ${GIT_REPO}"
    git clone ${GIT_REPO} /mnt/server/app > /dev/null 2>&1
fi

echo "[DONE] Installation complete!"