#!/bin/bash
GUID='99a3f756-fa2b-4b2a-8295-cdf8c50469b0'
DESCRIPTION='Install Papirus'
DEPENDS_ON=( )
#https://github.com/PiSupply/PaPiRus
echo "Before using PaPiRus, do not forget to enable the SPI and the I2C interfaces. \
     You can enable the SPI by typing sudo raspi-config at the command line and then \
     selecting Interfacing options > SPI and then selecting Enable. Without exiting \
     the tool still in Interfacing options > I2C and then selecting Enable."
echo ""
read -p "About to enter raspi-config (press any key to continue)"
sudo raspi-config
# Run this line and PaPiRus will be setup and installed
curl -sSL https://pisupp.ly/papiruscode | sudo bash

