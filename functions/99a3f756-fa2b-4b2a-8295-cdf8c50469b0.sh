#!/bin/bash
GUID='99a3f756-fa2b-4b2a-8295-cdf8c50469b0'
DESCRIPTION='Install Papirus'
DEPENDS_ON=( )
# Run this line and PaPiRus will be setup and installed
curl -sSL https://pisupp.ly/papiruscode | sudo bash
sudo papirus-set 1.44
papirus-system &