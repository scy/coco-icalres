// Please supply: Olav's sqlite3 database in the file "resources.sqlite"
// and the user name for which you want to export as command-line argument.

var icalevent = require('icalevent');

var sqlite3 = require('sqlite3').verbose();
var db = new sqlite3.Database('resources.sqlite');

var user = process.argv[2];
var uidUser = user.replace(/[^a-zA-Z]/g, '');

var days = {};
var events = [];

db.each('SELECT * FROM slots WHERE username = (?)', user, function (err, row) {
	if (err) {
		console.log(err);
		return;
	}
	if (!days[row.day]) {
		days[row.day] = [];
	}
	days[row.day][row.slot] = row.assignment;
}, function (err, count) {
	for (var date in days) {
		if (!days.hasOwnProperty(date)) {
			continue;
		}
		var percentage = {};
		var hasTask = false;
		days[date].forEach(function (task, idx) {
			if (task === '' || task === '---') {
				return;
			}
			hasTask = true;
			if (!percentage[task]) {
				percentage[task] = 0;
			}
			percentage[task] += 0.25;
		});
		if (hasTask) {
			var tasks = [];
			for (var task in percentage) {
				if (!percentage.hasOwnProperty(task)) {
					continue;
				}
				tasks.push(task + ' (' + (percentage[task] * 100) + '%)');
			}
			events.push({
				summary: tasks.join('; '),
				dt: date.replace(/[^0-9]/g, '')
			});
		}
	}
	var out = 'BEGIN:VCALENDAR\n';
	out += 'X-WR-CALNAME:Cocomore Ressourcen für ' + user + '\n';
	events.forEach(function (ev) {
		out += 'BEGIN:VEVENT\n';
		out += 'UID:coco-icalres-' + uidUser + '-' + ev.dt + '@cocomore.com\n';
		out += 'SUMMARY:' + ev.summary + '\n';
		out += 'DTSTART:' + ev.dt + '\n';
		out += 'END:VEVENT\n';
	});
	out += 'END:VCALENDAR\n';
	console.log(out);
	db.close();
});
