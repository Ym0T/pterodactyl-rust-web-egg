#!/bin/bash
# Rust Web Egg Installation Script
apt update
apt install -y curl git wget

cd /mnt/server

# Add VERSION file
wget -q -O - https://api.tavuru.de/version/Ym0T/pterodactyl-rust-web-egg | grep -o '"version":"[^"]*"' | cut -d'"' -f4 | head -1 > /mnt/server/VERSION

# Clone the default repository into a temporary directory
echo "[Git] Cloning default repository"
git clone https://github.com/Ym0T/pterodactyl-rust-web-egg /mnt/server/gtemp > /dev/null 2>&1 || { echo "[Git] Error: Default repository clone failed."; exit 21; }

# Copy necessary files
cp -r /mnt/server/gtemp/modules /mnt/server
cp /mnt/server/gtemp/start-modules.sh /mnt/server
cp /mnt/server/gtemp/LICENSE /mnt/server
chmod +x /mnt/server/start-modules.sh
find /mnt/server/modules -type f -name "*.sh" -exec chmod +x {} \;

# Remove temp directory
rm -rf /mnt/server/gtemp

# Create necessary directories
mkdir -p logs tmp data bin

# Clone or update the user repository if GIT_REPO is set
if [ -z "${GIT_REPO}" ]; then
    echo "[Git] GIT_REPO is not set, skipping."
else
    GIT_BRANCH="${GIT_BRANCH:-}"
    GIT_URL="${GIT_REPO}"

    # Without credentials and .git, so different spellings of the same repo match
    plain_url() { echo "$1" | sed -E 's|^(https?://)[^@/]*@|\1|; s|/$||; s|\.git$||'; }

    if [ -n "${USERNAME}" ] && [ -n "${ACCESS_TOKEN}" ]; then
        echo "[Git] Using authenticated Git access."
        GIT_URL="https://${USERNAME}:${ACCESS_TOKEN}@$(plain_url "${GIT_REPO}" | sed -E 's|^https?://||')"
    else
        echo "[Git] Using anonymous Git access."
    fi

    if [ -d /mnt/server/app/.git ]; then
        # Reinstall: update the existing checkout instead of deleting it
        cd /mnt/server/app || exit 1
        ORIGIN=$(git config --get remote.origin.url)
        if [ "$(plain_url "${ORIGIN}")" != "$(plain_url "${GIT_REPO}")" ]; then
            echo "[Git] Error: app/ contains a different repository, leaving it untouched."
            exit 13
        fi
        git remote set-url origin "${GIT_URL}"
        if [ -n "${GIT_BRANCH}" ]; then
            echo "[Git] Updating branch '${GIT_BRANCH}' in app/"
            git fetch --prune origin "${GIT_BRANCH}" > /dev/null 2>&1 || { echo "[Git] Error: git fetch failed for branch '${GIT_BRANCH}'."; exit 12; }
            git checkout "${GIT_BRANCH}" > /dev/null 2>&1 || git checkout -b "${GIT_BRANCH}" "origin/${GIT_BRANCH}" > /dev/null 2>&1 || { echo "[Git] Error: git checkout '${GIT_BRANCH}' failed."; exit 12; }
            git pull --ff-only origin "${GIT_BRANCH}" > /dev/null 2>&1 || { echo "[Git] Error: git pull failed for branch '${GIT_BRANCH}'."; exit 12; }
        else
            echo "[Git] Updating app/"
            git pull --ff-only > /dev/null 2>&1 || { echo "[Git] Error: git pull failed."; exit 12; }
        fi
        cd /mnt/server
    elif [ -d /mnt/server/app ] && [ -n "$(ls -A /mnt/server/app)" ]; then
        echo "[Git] Error: app/ contains files but no Git repository, leaving it untouched."
        exit 11
    else
        echo "[Git] Cloning user repository into app/"
        if [ -n "${GIT_BRANCH}" ]; then
            git clone --branch "${GIT_BRANCH}" --single-branch "${GIT_URL}" /mnt/server/app > /dev/null 2>&1 || { echo "[Git] Error: git clone failed (branch '${GIT_BRANCH}')."; exit 14; }
        else
            git clone "${GIT_URL}" /mnt/server/app > /dev/null 2>&1 || { echo "[Git] Error: git clone failed."; exit 14; }
        fi
    fi
fi

echo "[DONE] Installation complete!"