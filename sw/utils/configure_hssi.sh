# Paths
FPGA_BITSTREAM_FILENAME=/homes/sx233/ccip_std_afu.gbs
HSSI_CONFIG_SCRIPT=/export/fpga/opae/install/opae-install-default/bin/pac_hssi_config.py

# Flash FPGAs
fpgaconf -V ${FPGA_BITSTREAM_FILENAME} -B 0x18
fpgaconf -V ${FPGA_BITSTREAM_FILENAME} -B 0xaf

# Configure HSSI
sudo ${HSSI_CONFIG_SCRIPT} e40init 0000:18:00.0
sudo ${HSSI_CONFIG_SCRIPT} e40init 0000:af:00.0
