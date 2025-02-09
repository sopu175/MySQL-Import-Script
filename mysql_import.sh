#!/bin/bash

# Debugging: Enable tracing to show each command execution
set -x

# Check if all arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <path-to-sql-file> <mysql-username> <mysql-password> <database-name>"
    exit 1
fi

SQL_FILE="$1"
MYSQL_USER="$2"
MYSQL_PASS="$3"
DB_NAME="$4"

# Check if the file exists
if [ ! -f "$SQL_FILE" ]; then
    echo "Error: SQL file '$SQL_FILE' not found!"
    exit 1
fi

# Determine OS and set MySQL command location
OS=$(uname -s)
MYSQL_CMD="mysql"  # Default for Linux/macOS

if [[ "$OS" == *"MINGW"* || "$OS" == *"CYGWIN"* ]]; then  # Windows
    MYSQL_CMD="/c/xampp/mysql/bin/mysql.exe"
    if [ ! -x "$MYSQL_CMD" ]; then
        echo "Error: MySQL client not found at '$MYSQL_CMD'. Check XAMPP installation path."
        exit 1
    fi
elif [[ "$OS" == "Darwin" ]]; then  # macOS
    if [ -x "/usr/local/mysql/bin/mysql" ]; then
        MYSQL_CMD="/usr/local/mysql/bin/mysql"
    elif [ -x "/opt/homebrew/bin/mysql" ]; then
        MYSQL_CMD="/opt/homebrew/bin/mysql"
    fi
elif [[ "$OS" == "Linux" ]]; then
    if [ -x "/usr/bin/mysql" ]; then
        MYSQL_CMD="/usr/bin/mysql"
    elif [ -x "/usr/local/bin/mysql" ]; then
        MYSQL_CMD="/usr/local/bin/mysql"
    elif [ -x "/opt/lampp/bin/mysql" ]; then  # XAMPP on Linux
        MYSQL_CMD="/opt/lampp/bin/mysql"
    fi
fi

# Verify MySQL command exists
if ! test -x "$MYSQL_CMD"; then
    echo "Error: MySQL client not found or not executable. Check installation and permissions."
    exit 1
fi

# Construct MySQL password argument
MYSQL_PASS_ARG=""
if [[ -n "$MYSQL_PASS" ]]; then
    MYSQL_PASS_ARG="-p$MYSQL_PASS"
fi

# Check if database exists
DB_EXISTS=$("$MYSQL_CMD" -u "$MYSQL_USER" $MYSQL_PASS_ARG -e "SHOW DATABASES LIKE '$DB_NAME';" 2>/dev/null | grep -c "$DB_NAME")

if [[ "$DB_EXISTS" -eq 0 ]]; then
    # Create the database if it doesn't exist
    if ! "$MYSQL_CMD" -u "$MYSQL_USER" $MYSQL_PASS_ARG -e "CREATE DATABASE \`$DB_NAME\`;" 2>/dev/null; then
        echo "Error: Could not create database '$DB_NAME'. Check credentials and permissions."
        exit 1
    fi
    echo "Database '$DB_NAME' created successfully."
else
    echo "Database '$DB_NAME' already exists. Proceeding with import."
fi

# Determine file type and extract if necessary
EXTENSION="${SQL_FILE##*.}"
if [[ "$EXTENSION" == "gz" ]]; then
    gunzip -c "$SQL_FILE" | "$MYSQL_CMD" -u "$MYSQL_USER" $MYSQL_PASS_ARG "$DB_NAME" 2>/dev/null
elif [[ "$EXTENSION" == "zip" ]]; then
    unzip -p "$SQL_FILE" | "$MYSQL_CMD" -u "$MYSQL_USER" $MYSQL_PASS_ARG "$DB_NAME" 2>/dev/null
else
    "$MYSQL_CMD" -u "$MYSQL_USER" $MYSQL_PASS_ARG "$DB_NAME" < "$SQL_FILE" 2>/dev/null
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to import database '$DB_NAME'. Check credentials and SQL syntax."
    exit 1
fi

echo "Database '$DB_NAME' successfully imported from '$SQL_FILE'."

# Debugging: Turn off tracing
set +x