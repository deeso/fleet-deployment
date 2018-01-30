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
1) Update (hostname, CA crt location, and JWT_KEY) and run the following command:

```
 git clone https://github.com/deeso/fleet-deployment.git
cd fleet-deployment/fleet-ubuntu-host
bash setup_osquery_remote.sh -host NAME.kolide.tls.server \
-ca CA_CRT_ON_WEB_HOST -secret JWT_KEY
cd ../..
rm -rf fleet-deployment
```
