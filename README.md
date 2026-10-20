# Sailfish OS for Xiaomi Mi4c (`libra`)

Hardware Adaptation (HADK) port of Sailfish OS to the **Xiaomi Mi4c (codename `libra`)**, powered by the Qualcomm Snapdragon 808 (MSM8992) SoC.

[![Device: Xiaomi Mi4c](https://img.shields.io/badge/Device-Xiaomi%20Mi4c%20(libra)-orange.svg)](https://wiki.lineageos.org/devices/libra/)
[![Base: LineageOS 14.1](https://img.shields.io/badge/Base-LineageOS%2014.1%20(hybris--14.1)-brightgreen.svg)](https://github.com/mer-hybris/android)
[![Sailfish OS Target](https://img.shields.io/badge/Sailfish%20OS-4.5%20%2F%204.6-blue.svg)](https://sailfishos.org/)

---

## Device Specifications

| Attribute | Specification |
| :--- | :--- |
| **Model** | Xiaomi Mi 4c (`libra`) |
| **SoC** | Qualcomm MSM8992 Snapdragon 808 (2x Cortex-A57 + 4x Cortex-A53) |
| **GPU** | Adreno 418 |
| **RAM** | 2 GB / 3 GB LPDDR3 |
| **Architecture** | `aarch64` (ARM64-v8a) |
| **Display** | 1080 x 1920 IPS LCD (441 ppi, pixel ratio 2.0, DPI 440) |
| **Kernel Base** | Linux 3.10.x (`LineageOS/android_kernel_xiaomi_msm8992`) |
| **HAL Base** | Android 7.1.2 (LineageOS 14.1 / `hybris-14.1`) |

---

## Project Structure

```
├── SFOS_PORT_XIAOMI_LIBRA.md     # Full Agentic Execution Spec & Porting Blueprint
├── Containerfile.android_build   # Reproducible Ubuntu 16.04 container build environment
├── init_and_sync.sh              # Android HAL and local manifest sync script
├── docs/
│   └── hardware_charging_triage.md # Hardware diagnostic & fix for Type-C charging issues
└── patches/                      # Essential kernel and hybris-boot patches
    ├── 0001-kernel-msm8992-Makefile-Wno-error.patch
    ├── 0002-kernel-cgroup-uid_eq-compat.patch
    ├── 0003-hybris-boot-libra-mountpoints.patch
    └── 0004-device-libra-fstab-init-systemd.patch
```

---

## Porting Roadmap & Status

- [x] **[PHASE 1] Host Environment & Tooling**: Platform SDK and rootless container ready.
- [x] **[PHASE 2] Source Tree Sync**: Synced `hybris-14.1`, device tree, kernel, and vendor blobs (GitLab mirror).
- [x] **[PHASE 3] Kernel Adaptation**:
  - Enforced Mer & systemd flags (`CONFIG_DEVTMPFS`, `CONFIG_QUOTA`, `CONFIG_FHANDLE`, `CONFIG_ANDROID_PARANOID_NETWORK=n`).
  - Patched `fstab.qcom` and `init.qcom.rc` for systemd compatibility.
  - Zero fatal errors on `mer_verify_kernel_config`.
- [x] **[PHASE 4] Hybris HAL Build**:
  - Patched `Makefile` and `kernel/cgroup.c` for `uid_eq()` compatibility.
  - Generated `Image-dtb`, `hybris-boot.img` (31.7 MB), `hybris-recovery.img` (31.7 MB).
  - Injected `libra` eMMC partition mappings into `hybris-boot/fixup-mountpoints`.
  - Android HAL userland libraries compiled.
- [ ] **[PHASE 5] Droid HAL RPM Packaging**: Build `droid-hal-libra` and `droid-config-libra`.
- [ ] **[PHASE 6] Middleware & RootFS Assembly**: Build `libhybris` middleware and flashable release ZIP.
- [ ] **[PHASE 7] Hardware Bringup & Verification**: RNDIS debug, Wayland compositor, Audio, Modem, and Wi-Fi.

---

## Hardware Notes: Type-C Charging Diagnosis

If the Mi4c exhibits intermittent charging or rejects certain cables following a battery replacement, see [docs/hardware_charging_triage.md](docs/hardware_charging_triage.md). 
- **Cause**: Voltage drop over the main daughterboard-to-motherboard FPC ribbon trips the Qualcomm PMI8994 Under-Voltage Lockout (`usbin_uv_handler`), causing AICL to drop current to 0 mA.
- **Fix**: Reseat the FPC ribbon firmly, clean compacted lint from the Type-C port, and avoid USB-PD Type-C to Type-C chargers (use standard Type-A to Type-C with 56kΩ pull-up).

---

## License

- Kernel & Device Tree: GPL-2.0 / Apache-2.0
- Sailfish OS Adaptation Configurations: BSD-3-Clause
