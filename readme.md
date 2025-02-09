# MySQL Import Script

This script is designed to import MySQL database files (`.sql`, `.sql.gz`, `.zip`) into a specified database. It works across different operating systems, including Windows (XAMPP), macOS, and Linux.

## Features
- Supports `.sql`, `.sql.gz`, and `.zip` files.
- Checks if the database exists before importing.
- Automatically creates the database if it does not exist.
- Works with XAMPP on Windows and Linux.
- Handles MySQL authentication properly.

## Prerequisites
- Ensure MySQL is installed and accessible from the command line.
- For Windows users, ensure XAMPP is installed and MySQL is properly configured.

## Usage
Run the script using the following command:

```sh
./mysql_import.sh <path-to-sql-file> <mysql-username> <mysql-password> <database-name>
```

### Example:
```sh
./mysql_import.sh ./database.sql root "" my_database
```

### Example with a compressed file:
```sh
./mysql_import.sh ./backup.sql.gz root "" my_database
```

## Changing XAMPP Location
If you have installed XAMPP in a different location, update the `MYSQL_CMD` variable in the script.

1. Open the script `mysql_import.sh` in a text editor.
2. Locate the following line:
   ```sh
   MYSQL_CMD="/c/xampp-up/mysql/bin/mysql.exe"
   ```
3. Replace `/c/xampp-up/mysql/bin/mysql.exe` with the actual path to `mysql.exe` in your XAMPP installation.
   Example for default XAMPP installation:
   ```sh
   MYSQL_CMD="/c/xampp/mysql/bin/mysql.exe"
   ```

For Linux (XAMPP installed in `/opt/lampp/`), update:
```sh
MYSQL_CMD="/opt/lampp/bin/mysql"
```

## Troubleshooting
### Error: "MySQL client not found"
- Ensure MySQL is installed and correctly configured.
- Check the `MYSQL_CMD` variable in the script to match your MySQL installation.

### Error: "Access denied for user"
- Ensure the correct MySQL username and password are used.
- Try logging in manually:
  ```sh
  mysql -u root -p
  ```
  If login fails, reset the MySQL root password.

### Error: "Failed to import database"
- Ensure the `.sql`, `.sql.gz`, or `.zip` file is not corrupted.
- Check if the MySQL user has the necessary privileges.

## License
This script is open-source and free to use.

