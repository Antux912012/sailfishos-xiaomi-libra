%define vendor xiaomi
%define device libra
%define board_mapping msm8992
%define installable_zip 1
%define straggler_files \
/bt_firmware\
/firmware\
/persist\
/dsp\
%{nil}
%include rpm/dhd/droid-hal-device.inc
