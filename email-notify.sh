#!/bin/sh

#
#   Copyright 2013 Michał Rus <m@michalrus.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

#
# Add this to your crontab
#

TO="m@michalrus.com"
FROM="scripts@michalrus.com"
DIR="${HOME}/.irssi/email-notify"

find "$DIR" -mindepth 2 -maxdepth 2 -type d | while IFS= read -r HANDLE ; do
	if [ -n "$(find "$HANDLE" -type f -mmin +10)" ] ; then
		TMPFILE="${HANDLE}/"$(date +%s.%N)

		find "$HANDLE" -type f | sort | while IFS= read -r FILE ; do
			touch "$TMPFILE" || eval 'echo "Could not touch ${TMPFILE}" ; exit 1'
			cat "$FILE" >> "$TMPFILE"
			rm -f "$FILE"
		done

		if [ -f "${TMPFILE}" ] ; then
			(
				N="$(basename "$(dirname "$HANDLE")")"
				H="$(basename "$HANDLE")"
				echo "Content-Type: text/plain; charset=utf-8"
				echo "Content-Transfer-Encoding: 8bit"
				echo "From: Irssi <${FROM}>"
				echo "Subject: $H @ $N — new hilights."
				echo
				cat "${TMPFILE}"
			) | /usr/sbin/sendmail "${TO}" && rm "${TMPFILE}"
		fi
	fi
done
