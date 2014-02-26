#!/bin/sh

# Export all employees to .ics files in the bulk/ directory.
# Parameters:
#   $1: path to the sqlite database
#   $2: (optional) secret for the file name hash

export dbfile="$1"
shift

outdir='bulk'
mapping="$outdir/mapping.txt"

secret="$1"

for nodename in nodejs node; do
	NODE="$(which "$nodename" 2>/dev/null)"
	[ -n "$NODE" ] && break
done
if [ -z "$NODE" ]; then
	echo 'Node.js not found in the $PATH' >&2
	exit 1
fi

mkdir -p "$outdir"

: >"$mapping"
echo "AddType 'text/calendar; charset=UTF-8' ics" >"$outdir/.htaccess"

echo 'SELECT DISTINCT username FROM days;' | sqlite3 "$dbfile" | while read -r employee; do
	outfile="$(echo "$secret$employee" | sha1sum | cut -b 1-40).ics"
	echo "$employee -> $outfile ..."
	echo "$outfile $employee" >>"$mapping"
	"$NODE" coco-icalres.js "$employee" >"$outdir/$outfile" 2>/dev/null
done
