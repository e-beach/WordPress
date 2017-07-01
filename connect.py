import re
import mysql.connector
import sys

ERR_DB_EXISTS = 1007
MYSQL_CONF_PATH = "/etc/my.cnf"


config = {
    'user': 'root',
    'password': 'root',
    'host': 'localhost',
    'port': 8889,
    'raise_on_warnings': True,
}

class RunCounter:
    "Increment a counter each time script runs"

    def __init__(self, fname="run_counter"):
        self.fname = fname
        try:
            self.count = int(open(self.fname).read())
        except (OSError, ValueError):
            print("reading counter file {} failed".format(self.fname))
            self.count = 0

    def inc(self):
        self.count += 1
        with open(self.fname, "w") as fil:
            fil.write(str(self.count))


def createDatabase():
    global QUALIFIED_DB_NAME
    try:
        cursor.execute(
                "CREATE DATABASE {} DEFAULT CHARACTER SET 'utf8'".format(QUALIFIED_DB_NAME))
    except mysql.connector.Error as err:
                if err.errno == ERR_DB_EXISTS:
                    counter.inc()
                    QUALIFIED_DB_NAME = DB_NAME + str(counter.count)
                    createDatabase()
                else:
                    print("Failed creating database: {}".format(err))
                    exit(1)

def checkConfigForForceRecovery():
    try:
        sqlConfig = open(MYSQL_CONF_PATH).read()
    except OSError:
        print("Reading {} failed.".format(MYSQL_CONF_PATH))
    else:
        for line in sqlConfig.split("\n"):
            if re.match("innodb_force_recovery\s*=\s*1", line.strip()):
                print("You need to edit {} to turn off innodb_force_recovery = 1. Try:".format(MYSQL_CONF_PATH))
                print("sudo vim {}".format(MYSQL_CONF_PATH))
                exit(10)


if __name__ == "__main__":
    try:
        DB_NAME = sys.argv[1]
    except IndexError:
        DB_NAME = "wordpress"

    checkConfigForForceRecovery()

    counter = RunCounter()
    QUALIFIED_DB_NAME = DB_NAME + str(counter.count)

    connection = mysql.connector.connect(**config)
    cursor = connection.cursor()

    createDatabase()
    print("Created database {}".format(QUALIFIED_DB_NAME))
    counter.inc()
