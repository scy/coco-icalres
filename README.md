# coco-icalres
Creates iCal data based on the resource planning information.

This project will not be very useful to you except if you work at [Cocomore](http://www.cocomore.com/).

We assign developers to projects based on a large Excel sheet. My colleague [Olav](http://olav.net/) and I both hate looking at a large Excel sheet, so he created a script that will import its data into an SQLite database and make it available as a web frontend, and I created a script that will use that database to create iCal data that I can then import into Google Calendar or things like that.

What you're looking at is that second script.

## Installation

    npm install git+https://github.com/scy/coco-icalres

You need Node.js, of course.

## Usage

Supply the employee you want to create the iCal for as command line parameter. I use a cronjob like this to create it and publish it on the web for Google Calendar to find it:

    cd "$HOME/proj/coco-icalres" && curl -sO "$url_to_sqlite_db" && node coco-icalres.js 'Tim Weber' | ssh "$somewhere" 'cat > SOMEPATH' 2>/dev/null

## Author

This tool was written by Tim Weber. It basically is a hackish company-internal project, but if you need to contact me about it, feel free to do so.
