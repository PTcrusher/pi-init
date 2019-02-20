# pi-init

## Requirements

1. You must be running at least version 4.3 of bash.

```
bash --version
```

2. You must have a working SSH connection to the Pi. 

Follow the following steps to enable SSH in Raspbian Jessy
```bash
touch ssh
cat > wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=YOUR_COUNTRY_CODE
network={
    ssid="my-network-name"
    psk="my-network-pass"
    key_mgmt=WPA-PSK
}
EOF
```

3. Install GIT client

```
sudo apt-get update
sudo apt-get install git
```

## How to Run

Use the following commands to get started.
Additional standalone scripts should be added to the functions/ folder.
Please keep in mind that all scripts must have an **unique GUID and Description**, otherwise init.sh will not work properly.

```
git clone https://github.com/PTcrusher/pi-init.git
cd pi-init
chmod +x init.sh
./init.sh
```


