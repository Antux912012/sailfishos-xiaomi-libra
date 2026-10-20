# Sailfish OS for Xiaomi Mi4c (`libra`)

Hardware Adaptation (HADK) port of Sailfish OS to the **Xiaomi Mi4c (codename `libra`)**, powered by the Qualcomm Snapdragon 808 (MSM8992) SoC.

[![Device: Xiaomi Mi4c](https://img.shields.io/badge/Device-Xiaomi%20Mi4c%20(libra)-orange.svg)](https://wiki.lineageos.org/devices/libra/)
[![Base: LineageOS 14.1](https://img.shields.io/badge/Base-LineageOS%2014.1%20(hybris--14.1)-brightgreen.svg)](https://github.com/mer-hybris/android)
[![Sailfish OS Target](https://img.shields.io/badge/Sailfish%20OS-4.5%20%2F%204.6-blue.svg)](https://sailfishos.org/)

---

## 🎯 Aim of the Project

The primary goal of this project is to develop a complete, stable, and fully reproducible Sailfish OS Hardware Adaptation (HADK) for the **Xiaomi Mi4c (`libra`)**.

By pairing a patched 64-bit Linux 3.10.x kernel with the `hybris-14.1` (Android 7.1.2 / LineageOS 14.1) HAL base and the Jolla Sailfish OS 4.5.x userspace, this port aims to:
- Deliver an open, privacy-oriented GNU/Linux mobile experience powered by the native Sailfish Silica UI and Wayland compositor.
- Implement hardware-accelerated 2D/3D graphics and multimedia processing using `libhybris` and Qualcomm Adreno 418 driver glue.
- Ensure complete hardware coverage: dual-SIM telephony & mobile data (`ofono` / RIL), Wi-Fi (`wpa_supplicant`), Bluetooth (`bluez5`), PulseAudio droid routing, SensorFW, and camera (`droidmedia`).
- Maintain a fully containerized, reproducible build infrastructure (Platform SDK + Android HAL build containers) so any developer can audit, build, and extend the port.

---

## ⚠️ Disclaimer & Liability Notice

> **IMPORTANT DISCLAIMER:**  
> This project involves low-level firmware flashing, custom kernel deployment, bootloader interaction, and direct partition manipulation. **The author(s) and contributor(s) are NOT responsible for any damage caused to your device.**
>
> This includes, but is not limited to: hard bricks, unbootable states, bootloops, hardware burnout, flash memory degradation, loss of IMEI/baseband/EFS, or complete data loss.
>
> Proceed entirely at your own risk. Always make complete, verified raw backups of your eMMC partitions (`boot`, `system`, `data`, `persist`, `modem`, and `EFS`) via TWRP recovery before executing any commands or flashing custom images.

---

## Device Specifications

| Attribute | Specification |
| :--- | :--- |
| **Model** | Xiaomi Mi 4c (`libra`) |
| **Target Hardware** | **32 GB eMMC 5.0 ROM / 3 GB LPDDR3 RAM** (High Edition) |
| **SoC** | Qualcomm MSM8992 Snapdragon 808 (2x Cortex-A57 @ 1.82 GHz + 4x Cortex-A53 @ 1.44 GHz) |
| **GPU** | Qualcomm Adreno 418 @ 600 MHz |
| **Architecture** | `aarch64` (ARM64-v8a) |
| **Display** | 1080 x 1920 IPS LCD (441 ppi, pixel ratio 2.0, compositing DPI 440) |
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
