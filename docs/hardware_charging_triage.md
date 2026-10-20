# Xiaomi Mi4c (`libra`) Hardware Charging Triage & Post-Battery Fix

## Symptom
Following battery replacement, the device charges intermittently, stops charging unexpectedly, or charges only with specific, thick cables.

## Live Kernel Diagnostic
Live telemetry from the kernel log (`dmesg`) under ADB reveals the exact failure mode:
```text
[ 1442.963880] SMBCHG: usbin_uv_handler: chip->usb_present = 1 rt_sts = 0x05 aicl = 1000
[ 1442.964596] SMBCHG: smbchg_aicl_deglitch_wa_check: Charger removed
[ 1443.077565] SMBCHG: smbchg_set_thermal_limited_usb_current_max: AICL = 1000, ICL = 500
[ 1450.124368] SMBCHG: usbin_uv_handler: chip->usb_present = 0 rt_sts = 0x00 aicl = 1000
[ 1630.087940] SMBCHG: smbchg_set_usb_current_max: USB current_ma = 0
```

### Analysis
1. **USB Input Under-Voltage Lockout (`usbin_uv_handler`)**:
   - The Qualcomm SMBCHG (PMI8994) charger IC monitors $V_{\text{BUS}}$.
   - When charging starts and current ramps up towards 1000–1500 mA, the voltage sags below the chip's internal UVLO threshold.
   - The IC detects `rt_sts = 0x05` (Under-Voltage) and treats it as a sudden disconnect (`Charger removed`), resetting the input current limit to 0 mA.
   - With current stopped, $V_{\text{BUS}}$ bounces back up, the IC detects charger re-insertion, restarts charging, trips UVLO again, and oscillates indefinitely.

2. **Root Cause 1: Sub-Board FPC Ribbon Contact Resistance**:
   - The battery sits directly under the main flex ribbon linking the lower USB-C daughterboard to the motherboard.
   - Battery replacement requires disconnecting and reconnecting this ribbon. If seated with slight angular misalignment or uneven pressure, contact resistance on the $V_{\text{BUS}}$ and GND pins spikes.
   - Even a $0.5\,\Omega$ contact resistance causes a $0.75\,\text{V}$ drop at $1.5\,\text{A}$, collapsing 5.0V input to 4.25V and instantly triggering UVLO.

3. **Root Cause 2: Legacy Type-C Specification (2015)**:
   - The Mi4c uses early discrete Type-C hardware without Power Delivery (USB-PD).
   - Modern USB-C to USB-C cables and PD wall adapters fail or behave erratically.

---

## Actionable Fix Protocol

### 1. Re-seat the Main FPC Ribbon Cable
1. Disassemble the rear plastic housing.
2. Unclip the main motherboard-to-daughterboard FPC flex ribbon at **both** ends.
3. Clean the gold pin arrays with 99% isopropyl alcohol and a soft brush.
4. Align and press both ends down firmly until a flat, uniform click is felt.

### 2. Clean Type-C Port Debris
- Clear compacted pocket lint from the deep corners of the Type-C receptacle using a non-conductive pick so that the cable plug seats completely.

### 3. Proper Cable & Adapter Selection
- **Use**: Heavy-gauge USB Type-A to Type-C cables (20/22 AWG power lines) with standard 56kΩ pull-up resistor plugged into a 5V/2A or Quick Charge 2.0/3.0 wall charger.
- **Avoid**: High-wattage USB-C to USB-C Power Delivery cables/chargers.

### 4. Software BMS Calibration Reset
Reset the learned battery statistics via ADB:
```bash
adb shell dumpsys batterystats --reset
```
Perform a full charge cycle (charge to 100%, then discharge to ~5%) to let the fuel gauge re-learn cell capacity.
