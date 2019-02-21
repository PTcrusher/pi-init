#!/bin/bash
GUID='bcfe5615-b7ef-447e-8f5f-c4e682a0e935'
DESCRIPTION='Safe Shutdown Button (Pin 21)'
DEPENDS_ON=( '67952747-d79b-45fd-8678-62be0bebb822' )
#The .off_button script was authored by AndrewH7 and belongs to him (www.instructables.com/member/AndrewH7)
[ -f /home/pi/.off_button ] || cat > /home/pi/.off_button <<EOF
#!/bin/python
#This script was authored by AndrewH7 and belongs to him (www.instructables.com/member/AndrewH7)
#You have permission to modify and use this script only for your own personal usage
#You do not have permission to redistribute this script as your own work
#Use this script at your own risk

import RPi.GPIO as GPIO
import os

GPIO.setwarnings(False)

gpio_pin_number=21
#Replace YOUR_CHOSEN_GPIO_NUMBER_HERE with the GPIO pin number you wish to use
#Make sure you know which rapsberry pi revision you are using first
#The line should look something like this e.g. "gpio_pin_number=7"

GPIO.setmode(GPIO.BCM)
#Use BCM pin numbering (i.e. the GPIO number, not pin number)
#WARNING: this will change between Pi versions
#Check yours first and adjust accordingly

#GPIO.setup(gpio_pin_number, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(gpio_pin_number, GPIO.IN)
#It's very important the pin is an input to avoid short-circuits
#The pull-up resistor means the pin is high by default

try:
    GPIO.wait_for_edge(gpio_pin_number, GPIO.FALLING)
    #Use falling edge detection to see if pin is pulled
    #low to avoid repeated polling
    os.system("sudo shutdown -h now")
    #Send command to system to shutdown
except:
    pass

GPIO.cleanup()
#Revert all GPIO pins to their normal states (i.e. input = safe)
EOF
if [ `grep "off_button" /etc/rc.local | wc -l` -eq 0 ]
then
    sudo cp /etc/rc.local /etc/rc.local.bck
    head -n -1 /etc/rc.local.bck | sudo tee /etc/rc.local
    echo -e "python /home/pi/.off_button &\nexit 0" | sudo tee -a /etc/rc.local
    python /home/pi/.off_button &
fi