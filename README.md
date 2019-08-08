# sample-flask-app
Sample Todo Manager application with Flask and SQLAlchemy

* Requirements :
Please execute the following commands:
```
$ sudo yum install git python3-virtualenv python3-pip sqlitebrowser
$ git clone git@github.com:AmitVasantSalunke/sample-flask-app.git
$ cd ./sample-flask-app
$ virtualenv --python=/usr/bin/python3 venv
$ source ./venv/bin/activate
$ pip3 install -r requirements.txt
```

* Execution :

Please execute the following command:
```
$ export POSTGRES_SERVER=10.46.140.215
$ export POSTGRES_USER="postgres"
$ export POSTGRES_PASSWORD="Nutanix/4u"
$ export POSTGRES_DATABASE="era_pg_db" 
$ python3 taskmanager.py
```


#!/bin/bash
set -ex
# Install python3, httpd and flask
sudo yum -y update
sudo yum -y install epel-release
sudo yum -y install httpd gcc git psacct python36 python36-devel python36-pip mod_proxy_uwsgi 
sudo yum clean all

# Init and activate a python-virtualenv with prereqs
python3 -m venv /home/centos/sample-flask-app/env
source env/bin/activate && pip install -r /home/centos/sample-flask-app/requirements.txt
git clone git@github.com:AmitVasantSalunke/sample-flask-app.git

echo "[Unit]
Description=uWSGI server for ntnxdemoapp
After=network.target

[Service]
User=centos
Group=apache
WorkingDirectory=/home/centos/sample-flask-app
Environment='PATH=/home/centos/sample-flask-app/env/bin'
ExecStart=/home/centos/sample-flask-app/env/bin/uwsgi --ini /home/centos/sample-flask-app/app.ini

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/ntnxdemoapp.service

echo "LoadModule proxy_uwsgi_module modules/mod_proxy_uwsgi.so
<VirtualHost *>
    ServerName ntnxdemoapp.com
    ProxyPass / uwsgi://127.0.0.1:8000
</VirtualHost> " | sudo tee -a /etc/httpd/conf/httpd.conf

sudo systemctl enable ntnxdemoapp
sudo systemctl start ntnxdemoapp

sudo systemctl restart httpd
sudo systemctl enable httpd





