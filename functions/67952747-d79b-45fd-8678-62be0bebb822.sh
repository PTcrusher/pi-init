#!/bin/bash
GUID='67952747-d79b-45fd-8678-62be0bebb822'
DESCRIPTION='RaspberryPi GPIO Python Package (Raspbian Stretch Lite)'
DEPENDS_ON=( )
sudo apt-get install python-pip
pip install RPi.GPIO
sudo apt-get install picap
picap-setup