#!/bin/bash

source /home/centos/sample-flask-app/config.env && /home/centos/sample-flask-app/env/bin/uwsgi --ini /home/centos/sample-flask-app/app.ini