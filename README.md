# sample-flask-app
Sample Todo Manager application with Flask and SQLAlchemy

* Requirements :
Please execute the following commands:

$ sudo yum install git python3-virtualenv python3-pip sqlitebrowser
$ git clone git@github.com:AmitVasantSalunke/sample-flask-app.git
$ cd ./sample-flask-app
$ virtualenv --python=/usr/bin/python3 venv
$ source ./venv/bin/activate
$ pip3 install -r requirements.txt

* Execution :
Please execute the following command:
$ export POSTGRES_SERVER=10.46.140.215
$ export POSTGRES_USER="postgres"
$ export POSTGRES_PASSWORD="Nutanix/4u"
$ export POSTGRES_DATABASE="era_pg_db" 
$ python3 taskmanager.py