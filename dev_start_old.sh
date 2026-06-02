#!/bin/bash
# virtual environment de python con Flask, Flask_MySQLdb, PyMySQL y mysqlclient
source ../bin/activate

# applicacion de flask
export FLASK_APP="app.py"
export FLASK_DEBUG=1
flask run --host=0.0.0.0 --port=8080 --debug
