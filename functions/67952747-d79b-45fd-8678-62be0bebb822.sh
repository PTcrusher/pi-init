#!/bin/bash
GUID='67952747-d79b-45fd-8678-62be0bebb822'
DESCRIPTION='RaspberryPi GPIO Python Package'
DEPENDS_ON=( )

[ `dpkg -l | grep -E '^ii' | grep python-pip | wc -l` -eq 0 ] && sudo apt-get install python-pip
[ `pip show RPi.GPIO | wc -l` -eq 0 ] && pip install RPi.GPIO
