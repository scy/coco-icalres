#!/bin/sh
set -e

if [ "$#" -lt 1 ]; then
	echo 'please supply Excel file path as a parameter' >&2
	exit 1
fi

olav='olav-resources'
var="$olav/var"
xlssrc="$1"
xlsdest="$var/Ressourcenplanung 2013.xlsx" # As defined in app.php
db_ini="database.ini"
db_file="$var/resources.sqlite"
db_schema="$olav/schema.sql"

if [ ! -e "$xlssrc" ]; then
	echo "there is no file at $xlssrc" >&2
	exit 2
fi

# Prepare the var/ directory.
mkdir -p "$var"

# If there's no database.ini, use the default.
if [ ! -e "$olav/$db_ini" -a ! -L "$olav/$db_ini" ]; then
	ln -s "$db_ini.default" "$olav/$db_ini"
fi

# Copy the Excel sheet.
cp "$xlssrc" "$xlsdest"

# Clear or init the sqlite file.
if [ -e "$db_file" ]; then
	echo 'DELETE FROM days;' | sqlite3 "$db_file" 2>/dev/null || sqlite3 "$db_file" < "$db_schema"
else
	sqlite3 "$db_file" < "$db_schema"
fi

# Run the import.
cd "$olav"
REQUEST_URI=/update php -d memory_limit=512M index.php
cd - >/dev/null
