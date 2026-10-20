#!/bin/bash
set -e

echo "=== Initializing Sailfish OS (hybris-14.1) Tree for Xiaomi Mi4c (libra) ==="
export ANDROID_ROOT="${ANDROID_ROOT:-$HOME/hadk}"
mkdir -p "$ANDROID_ROOT"
cd "$ANDROID_ROOT"

# Initialize minimal mer-hybris Android base
repo init -u https://github.com/mer-hybris/android.git -b hybris-14.1 --depth=1

# Inject local manifests for libra
mkdir -p .repo/local_manifests
cat << 'EOF' > .repo/local_manifests/libra.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote fetch="https://gitlab.com/" name="gitlab" />
  <project name="LineageOS/android_device_xiaomi_libra" path="device/xiaomi/libra" remote="github2" revision="cm-14.1" />
  <project name="LineageOS/android_kernel_xiaomi_msm8992" path="kernel/xiaomi/msm8992" remote="github2" revision="cm-14.1" />
  <project name="the-muppets/proprietary_vendor_xiaomi" path="vendor/xiaomi" remote="gitlab" revision="cm-14.1" clone-depth="1" />
</manifest>
EOF

echo "Syncing device, kernel, and vendor repositories..."
repo sync -c -j"$(nproc)" --fetch-submodules --no-clone-bundle --force-sync

echo "=== Sync complete! Device and kernel sources ready. ==="
