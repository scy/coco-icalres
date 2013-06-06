#!/bin/sh

# Simple update script. Will fetch the sqlite, do an export and scp that export
# to some other place. Expects four parameters:
#  - URL where to get the SQLite database
#  - employee name to generate the export for
#  - host to scp to
#  - path on that host to scp to

url="$1"
shift

employee="$1"
shift

host="$1"
shift

path="$1"
shift

dbfile='resources.sqlite'
icalfile='resources.ics'

if ! curl -so "$dbfile" "$url"; then
	echo "error running curl for $url" >&2
	exit 1
fi

if ! [ -s "$dbfile" ]; then
	echo "error downloading $dbfile from $url" >&2
	exit 1
fi

node coco-icalres.js "$employee" > "$icalfile" 2>/dev/null
if ! [ -s "$icalfile" ]; then
	echo "generated ical file is empty" >&2
	exit 1
fi

if ! scp -q "$icalfile" "$host":"$path"; then
	echo "problem SCPing the file to $host:$path" >&2
	exit 1
fi
