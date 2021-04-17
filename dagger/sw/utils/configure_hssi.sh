# Paths
FPGA_BITSTREAM_FILENAME=/homes/sx233/ccip_std_afu.gbs
HSSI_CONFIG_SCRIPT=/export/fpga/opae/install/opae-install-default/bin/pac_hssi_config.py
HSSI_CONFIG_BIN=/homes/sx233/fpga-pac-opae/sw/

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HSSI_CONFIG_BIN}

# Flash FPGAs
fpgaconf -V ${FPGA_BITSTREAM_FILENAME} -B 0x18
fpgaconf -V ${FPGA_BITSTREAM_FILENAME} -B 0xaf

# Configure HSSI
sudo ${HSSI_CONFIG_SCRIPT} e40init 0000:18:00.0
sudo ${HSSI_CONFIG_SCRIPT} e40init 0000:af:00.0

# Disable HSSI loopback
${HSSI_CONFIG_BIN}/pac_hssi_e40 -b 0x18 --action=loopback_disable
${HSSI_CONFIG_BIN}/pac_hssi_e40 -b 0xaf --action=loopback_disable

# Clear statistics
${HSSI_CONFIG_BIN}/pac_hssi_e40 -b 0x18 --action=stat_clear
${HSSI_CONFIG_BIN}/pac_hssi_e40 -b 0xaf --action=stat_clear
