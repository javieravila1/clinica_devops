from flask import current_app
from flask_mysqldb import MySQL

# Install pymysql as MySQLdb
import pymysql
pymysql.install_as_MySQLdb()

# This will be initialized by the main app
mysql = None

def init_db(app):
    """Initialize the database connection"""
    global mysql
    mysql = MySQL(app)
    return mysql
