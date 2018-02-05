Simple deployment for Fleet Binary
==================================

Installs the fleet binary on an Ubuntu box.

How to Use Install (kolide/fleet installation)
==============================================

```
https://github.com/deeso/fleet-deployment
cd fleet-deployment/fleet-server-install
```

`#` if you're using your own ssl certs
`#     `copy them to the *ssl* folder 
`#` else 
`#     ` installer help generate them
`#` create your own config 

`bash install.sh <your-file>.yaml`


`#`  no config, no problem
`cp passwords.example passwords.sh`
`#`  and update the MYSQL_PASS and JWT_KEY variable with the sql password
`bash install.sh`

How to Use Install (fleet-host installation)
==============================================
**Special Notes:** 
**1)** Post CA signing the kolide's TLS Cert on a web server somewhere (internally or externally).  The install script will pull the CA certificate from there and perform the installation.
**2)** Obtain the JWT_KEY from the install.  This 

### adding the fleet host
0) Install **osquery** and **git** on the target host
1) Update (hostname, CA crt location, and ENROLLMENT_KEY).  The ENROLLMENT_KEY can be found under the Admin->App Settings under the "OSQuery Enrollment Secret".  After obtaining and updating the values, run the following command:

```
 git clone https://github.com/deeso/fleet-deployment.git
cd fleet-deployment/fleet-ubuntu-host
bash setup_osquery_remote.sh -host NAME.kolide.tls.server \
-ca CA_CRT_ON_WEB_HOST -secret ENROLLMENT_KEY
cd ../..
rm -rf fleet-deployment
```

Setting up Linux Development Box
================================

### Install dependencies

sudo apt-get install xzip gyp libjs-underscore libuv1-dev dep11-tools deps-tools-cli 

### Create a temp directory, download and place the **node** and **golang** bins 
mkdir tmp
cd tmp

#### install **node** and **yarn**
wget https://nodejs.org/dist/v9.4.0/node-v9.4.0-linux-x64.tar.xz
xz -d node-v9.4.0-linux-x64.tar.xz
tar -xf node-v9.4.0-linux-x64.tar
sudo cp -rf node-v9.4.0-linux-x64/bin /usr/local/
sudo cp -rf node-v9.4.0-linux-x64/include /usr/local
sudo cp -rf node-v9.4.0-linux-x64/lib /usr/local
sudo cp -rf node-v9.4.0-linux-x64/share /usr/local
npm install -g yarn

#### install **go**
wget https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.9.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin:~/go/bin/

#### clean-up temp directory
cd ..
rm -rf tmp

### Clone and build depenencies
cd ~/go/src
git get github.com/kolide/fleet
cd github.com/kolide/fleet
make deps
make generate
make build
